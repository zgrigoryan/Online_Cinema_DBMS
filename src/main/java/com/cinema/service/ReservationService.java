package com.cinema.service;

import com.cinema.domain.enums.PaymentStatus;
import com.cinema.domain.enums.ReservationStatus;
import com.cinema.domain.enums.SessionStatus;
import com.cinema.domain.enums.TicketStatus;
import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Payment;
import com.cinema.domain.model.Promotion;
import com.cinema.domain.model.Reservation;
import com.cinema.domain.model.Seat;
import com.cinema.domain.model.Session;
import com.cinema.domain.model.Ticket;
import com.cinema.repository.CustomerRepository;
import com.cinema.repository.PaymentRepository;
import com.cinema.repository.PromotionRepository;
import com.cinema.repository.ReservationRepository;
import com.cinema.repository.SeatRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.repository.TicketRepository;
import java.time.OffsetDateTime;
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
  private final PromotionRepository promotionRepository;
  private final SessionService sessionService;
  private final PaymentRepository paymentRepository;

  public ReservationService(ReservationRepository reservationRepository,
                            CustomerRepository customerRepository,
                            SessionRepository sessionRepository,
                            SeatRepository seatRepository,
                            TicketRepository ticketRepository,
                            PromotionService promotionService,
                            PromotionRepository promotionRepository,
                            SessionService sessionService,
                            PaymentRepository paymentRepository) {
    this.reservationRepository = reservationRepository;
    this.customerRepository = customerRepository;
    this.sessionRepository = sessionRepository;
    this.seatRepository = seatRepository;
    this.ticketRepository = ticketRepository;
    this.promotionService = promotionService;
    this.promotionRepository = promotionRepository;
    this.sessionService = sessionService;
    this.paymentRepository = paymentRepository;
  }

  @Transactional
  public Reservation createReservation(@NonNull Long customerId, @NonNull Long sessionId, @NonNull List<Long> seatIds, String promotionCode) {
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    Session session = sessionRepository.findById(sessionId)
        .orElseThrow(() -> new IllegalArgumentException("Session not found"));
    if (!(session.getStatus() == SessionStatus.SCHEDULED || session.getStatus() == SessionStatus.ACTIVE)) {
      throw new IllegalStateException("Cannot reserve seats for inactive session");
    }
    if (session.getStartTime().isBefore(OffsetDateTime.now())) {
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
      if (ticketRepository.existsBySessionAndSeat(session, seat)) {
        throw new IllegalStateException("Seat already booked for this session");
      }
    });

    double total = session.getBasePrice() * seats.size();
    Promotion promotion = null;
    if (promotionCode != null && !promotionCode.isBlank()) {
      promotion = promotionService.validatePromotion(promotionCode, total);
      double discount = total * promotion.getDiscountPercent() / 100.0;
      total = total - discount;
      promotion.setTimesRedeemed(promotion.getTimesRedeemed() + 1);
      promotionRepository.save(promotion);
    }

    Reservation reservation = new Reservation();
    reservation.setCustomer(customer);
    reservation.setSession(session);
    reservation.setPromotion(promotion);
    reservation.setStatus(ReservationStatus.CONFIRMED);
    reservation.setReservedAt(OffsetDateTime.now());
    reservation.setTotalAmount(total);

    seats.forEach(seat -> {
      Ticket ticket = new Ticket();
      ticket.setReservation(reservation);
      ticket.setSeat(seat);
      ticket.setSession(session);
      ticket.setPrice(session.getBasePrice());
      ticket.setStatus(TicketStatus.ACTIVE);
      reservation.getTickets().add(ticket);
    });
    sessionService.adjustAvailableSeats(session, -seats.size());

    Payment payment = new Payment();
    payment.setReservation(reservation);
    payment.setAmount(total);
    payment.setStatus(PaymentStatus.PAID);
    payment.setMethod("CARD");
    payment.setPaidAt(OffsetDateTime.now());
    reservation.setPayment(payment);

    Reservation saved = reservationRepository.save(reservation);
    paymentRepository.save(payment);
    return saved;
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
    reservation.getTickets().forEach(t -> t.setStatus(TicketStatus.CANCELLED));
    sessionService.adjustAvailableSeats(reservation.getSession(), reservation.getTickets().size());
    Payment payment = reservation.getPayment();
    if (payment != null && payment.getStatus() == PaymentStatus.PAID) {
      payment.setStatus(PaymentStatus.REFUNDED);
      paymentRepository.save(payment);
    }
    return reservationRepository.save(reservation);
  }
}
