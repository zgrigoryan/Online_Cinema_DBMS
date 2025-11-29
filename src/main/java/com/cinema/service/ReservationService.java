package com.cinema.service;

import com.cinema.domain.enums.ReservationStatus;
import com.cinema.domain.enums.PaymentMethod;
import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Payment;
import com.cinema.domain.model.Promotion;
import com.cinema.domain.model.Reservation;
import com.cinema.domain.model.Seat;
import com.cinema.domain.model.Session;
import com.cinema.domain.model.Ticket;
import com.cinema.repository.CustomerRepository;
import com.cinema.repository.PaymentRepository;
import com.cinema.repository.ReservationRepository;
import com.cinema.repository.SeatRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.repository.TicketRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReservationService {

  private final ReservationRepository reservationRepository;
  private final CustomerRepository customerRepository;
  private final SessionRepository sessionRepository;
  private final SeatRepository seatRepository;
  private final TicketRepository ticketRepository;
  private final PromotionService promotionService;
  private final SessionService sessionService;
  private final PaymentRepository paymentRepository;

  public ReservationService(ReservationRepository reservationRepository,
                            CustomerRepository customerRepository,
                            SessionRepository sessionRepository,
                            SeatRepository seatRepository,
                            TicketRepository ticketRepository,
                            PromotionService promotionService,
                            SessionService sessionService,
                            PaymentRepository paymentRepository) {
    this.reservationRepository = reservationRepository;
    this.customerRepository = customerRepository;
    this.sessionRepository = sessionRepository;
    this.seatRepository = seatRepository;
    this.ticketRepository = ticketRepository;
    this.promotionService = promotionService;
    this.sessionService = sessionService;
    this.paymentRepository = paymentRepository;
  }

  @Transactional
  public Reservation createReservation(@NonNull Long customerId, @NonNull Long sessionId, @NonNull List<Long> seatIds, String promotionCode) {
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    Session session = sessionRepository.findById(sessionId)
        .orElseThrow(() -> new IllegalArgumentException("Session not found"));
    if (session.getStartTime().isBefore(LocalDateTime.now())) {
      throw new IllegalStateException("Cannot reserve seats for past sessions");
    }
    List<Seat> seats = seatRepository.findAllById(seatIds);
    if (seats.size() != seatIds.size()) {
      throw new IllegalArgumentException("One or more seats not found");
    }
    seats.forEach(seat -> {
      if (!seat.getHall().getId().equals(session.getHall().getId())) {
        throw new IllegalArgumentException("Seat does not belong to session hall");
      }
      if (ticketRepository.existsByReservation_SessionAndSeat(session, seat)) {
        throw new IllegalStateException("Seat already booked for this session");
      }
    });

    BigDecimal total = session.getSessionPrice().multiply(BigDecimal.valueOf(seats.size()));
    Promotion promotion = null;
    if (promotionCode != null && !promotionCode.isBlank()) {
      promotion = promotionService.validatePromotion(promotionCode, total);
      total = total.subtract(promotion.getDiscountAmount());
      if (total.compareTo(BigDecimal.ZERO) < 0) {
        total = BigDecimal.ZERO;
      }
    }

    Reservation reservation = new Reservation();
    reservation.setCustomer(customer);
    reservation.setSession(session);
    reservation.setStatus(ReservationStatus.CONFIRMED);
    reservation.setReservationDate(LocalDateTime.now());
    reservation.setTotalAmount(total);

    int ticketNumber = 1;
    for (Seat seat : seats) {
      Ticket ticket = new Ticket();
      ticket.setReservation(reservation);
      ticket.setTicketNumber(ticketNumber++);
      ticket.setSeat(seat);
      ticket.setTicketPrice(session.getSessionPrice());
      ticket.setPurchaseDate(LocalDateTime.now());
      reservation.getTickets().add(ticket);
    }
    sessionService.adjustAvailableSeats(session, -seats.size());

    Payment payment = new Payment();
    payment.setPromotion(promotion);
    payment.setFinalAmount(total);
    payment.setPaymentMethod(PaymentMethod.CREDIT_CARD);
    payment.setPaymentDate(LocalDateTime.now());
    Payment savedPayment = paymentRepository.save(payment);

    reservation.setPayment(savedPayment);

    return reservationRepository.save(reservation);
  }

  @Transactional
  public Reservation cancelReservation(Long reservationId, Long customerId) {
    if (reservationId == null) {
      throw new IllegalArgumentException("Reservation ID cannot be null");
    }
    Reservation reservation = reservationRepository.findById(reservationId)
        .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));
    if (!reservation.getCustomer().getId().equals(customerId)) {
      throw new IllegalStateException("Cannot cancel reservation of another user");
    }
    if (reservation.getStatus() == ReservationStatus.CANCELLED) {
      return reservation;
    }
    reservation.setStatus(ReservationStatus.CANCELLED);
    sessionService.adjustAvailableSeats(reservation.getSession(), reservation.getTickets().size());
    return reservationRepository.save(reservation);
  }

  @Transactional(readOnly = true)
  public List<Reservation> getHistory(Long customerId) {
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    return reservationRepository.findByCustomerOrderByReservationDateDesc(customer);
  }
}
