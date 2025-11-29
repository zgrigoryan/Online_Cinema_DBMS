package com.cinema.service;

import com.cinema.domain.enums.PaymentMethod;
import com.cinema.domain.enums.ReservationStatus;
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
import java.util.Comparator;
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

    List<Seat> sortedSeats = seats.stream()
        .sorted(Comparator.comparing(Seat::getRowNumber).thenComparing(Seat::getSeatNumber))
        .toList();

    BigDecimal total = BigDecimal.ZERO;

    Reservation reservation = new Reservation();
    reservation.setCustomer(customer);
    reservation.setSession(session);
    reservation.setStatus(ReservationStatus.PENDING);
    reservation.setReservationDate(LocalDateTime.now());
    reservation.setTotalAmount(total);

    int ticketNumber = 1;
    for (Seat seat : sortedSeats) {
      BigDecimal ticketPrice = priceForSeat(session, seat);
      total = total.add(ticketPrice);
      Ticket ticket = new Ticket();
      ticket.setReservation(reservation);
      ticket.setTicketNumber(ticketNumber++);
      ticket.setSeat(seat);
      ticket.setTicketPrice(ticketPrice);
      ticket.setPurchaseDate(LocalDateTime.now());
      reservation.getTickets().add(ticket);
    }
    reservation.setTotalAmount(total);
    sessionService.adjustAvailableSeats(session, -sortedSeats.size());

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
    if (reservation.getSession().getStartTime().isBefore(LocalDateTime.now())) {
      throw new IllegalStateException("Cannot cancel after session start");
    }
    if (reservation.getStatus() == ReservationStatus.CANCELLED) {
      return reservation;
    }
    reservation.setStatus(ReservationStatus.CANCELLED);
    int ticketCount = reservation.getTickets().size();
    reservation.getTickets().clear();
    sessionService.adjustAvailableSeats(reservation.getSession(), ticketCount);
    Payment payment = reservation.getPayment();
    if (payment != null) {
      payment.setFinalAmount(BigDecimal.ZERO);
      paymentRepository.save(payment);
    }
    return reservationRepository.save(reservation);
  }

  @Transactional(readOnly = true)
  public List<Reservation> getHistory(Long customerId) {
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    return reservationRepository.findByCustomerOrderByReservationDateDesc(customer);
  }

  @Transactional(readOnly = true)
  public List<com.cinema.web.dto.reservation.ReservationHistoryResponse> getHistoryDetailed(Long customerId) {
    return getHistory(customerId).stream().map(res -> {
      Session s = res.getSession();
      var tickets = res.getTickets().stream()
          .map(t -> new com.cinema.web.dto.reservation.ReservationHistoryResponse.TicketInfo(
              t.getSeat().getRowNumber(),
              t.getSeat().getSeatNumber(),
              t.getSeat().getCategory(),
              t.getTicketPrice()))
          .toList();
      return new com.cinema.web.dto.reservation.ReservationHistoryResponse(
          res.getId(),
          res.getStatus().name(),
          res.getReservationDate(),
          res.getTotalAmount(),
          s.getId(),
          s.getShowDate(),
          s.getStartTime().toLocalTime(),
          s.getEndTime().toLocalTime(),
          s.getMovie().getTitle(),
          s.getHall().getName(),
          res.getPayment() != null && res.getPayment().getPromotion() != null ? res.getPayment().getPromotion().getCode() : null,
          res.getPayment() != null ? res.getPayment().getId() : null,
          tickets
      );
    }).toList();
  }

  @Transactional
  public Reservation purchaseReservation(Long reservationId, PaymentMethod method, String promotionCode) {
    Reservation reservation = reservationRepository.findById(reservationId)
        .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));
    if (reservation.getStatus() != ReservationStatus.PENDING) {
      throw new IllegalStateException("Only pending reservations can be purchased");
    }
    Session session = reservation.getSession();
    if (session.getStartTime().isBefore(LocalDateTime.now())) {
      throw new IllegalStateException("Cannot purchase past session");
    }
    BigDecimal total = reservation.getTickets().stream()
        .map(Ticket::getTicketPrice)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    Promotion promotion = null;
    if (promotionCode != null && !promotionCode.isBlank()) {
      promotion = promotionService.validatePromotion(promotionCode, total);
      total = total.subtract(promotion.getDiscountAmount());
      if (total.compareTo(BigDecimal.ZERO) < 0) {
        total = BigDecimal.ZERO;
      }
    }
    Payment payment = new Payment();
    payment.setPromotion(promotion);
    payment.setFinalAmount(total);
    payment.setPaymentMethod(method);
    payment.setPaymentDate(LocalDateTime.now());
    Payment savedPayment = paymentRepository.save(payment);

    reservation.setPayment(savedPayment);
    reservation.setTotalAmount(total);
    reservation.setStatus(ReservationStatus.CONFIRMED);
    return reservationRepository.save(reservation);
  }

  private BigDecimal priceForSeat(Session session, Seat seat) {
    BigDecimal base = seat.getBasePrice() != null ? seat.getBasePrice() : BigDecimal.ZERO;
    BigDecimal multiplier = SessionService.CATEGORY_MULTIPLIER.getOrDefault(
        seat.getCategory() != null ? seat.getCategory().toUpperCase() : "STANDARD",
        BigDecimal.ONE);
    return session.getSessionPrice().multiply(multiplier).add(base);
  }
}
