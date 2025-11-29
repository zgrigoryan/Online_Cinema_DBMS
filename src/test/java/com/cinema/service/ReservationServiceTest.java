package com.cinema.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import com.cinema.domain.enums.MembershipStatus;
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
import com.cinema.web.dto.session.SeatAvailability;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

class ReservationServiceTest {

  @Mock private ReservationRepository reservationRepository;
  @Mock private CustomerRepository customerRepository;
  @Mock private SessionRepository sessionRepository;
  @Mock private SeatRepository seatRepository;
  @Mock private TicketRepository ticketRepository;
  @Mock private PaymentRepository paymentRepository;
  private PromotionService promotionService;
  private SessionService sessionService;
  private ReservationService reservationService;

  @BeforeEach
  void init() {
    MockitoAnnotations.openMocks(this);
    promotionService = new StubPromotionService();
    sessionService = new NoopSessionService();
    reservationService = new ReservationService(
        reservationRepository,
        customerRepository,
        sessionRepository,
        seatRepository,
        ticketRepository,
        promotionService,
        sessionService,
        paymentRepository);
  }

  @Test
  void createReservationUsesPerSeatPricingAndPendingStatus() {
    Customer customer = new Customer();
    customer.setId(1L);
    customer.setMembershipStatus(MembershipStatus.REGULAR);

    Session session = new Session();
    session.setId(10L);
    session.setSessionPrice(BigDecimal.valueOf(100));
    session.setHall(new com.cinema.domain.model.CinemaHall());
    session.getHall().setId(5L);
    session.getHall().setCapacity(200);
    session.setAvailableSeats(200);
    session.setStartTime(LocalDateTime.now().plusDays(1));

    Seat vipSeat = new Seat();
    vipSeat.setId(101L);
    vipSeat.setHall(session.getHall());
    vipSeat.setRowNumber(1);
    vipSeat.setSeatNumber(1);
    vipSeat.setCategory("VIP");
    vipSeat.setBasePrice(BigDecimal.valueOf(20));

    Seat standardSeat = new Seat();
    standardSeat.setId(102L);
    standardSeat.setHall(session.getHall());
    standardSeat.setRowNumber(1);
    standardSeat.setSeatNumber(2);
    standardSeat.setCategory("Standard");
    standardSeat.setBasePrice(BigDecimal.valueOf(10));

    when(customerRepository.findById(1L)).thenReturn(Optional.of(customer));
    when(sessionRepository.findById(10L)).thenReturn(Optional.of(session));
    when(seatRepository.findAllById(List.of(101L, 102L))).thenReturn(List.of(vipSeat, standardSeat));
    when(ticketRepository.existsByReservation_SessionAndSeat(any(), any())).thenReturn(false);
    when(reservationRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    Reservation res = reservationService.createReservation(1L, 10L, List.of(101L, 102L), null);

    assertEquals(ReservationStatus.PENDING, res.getStatus());
    // vip: 100 * 1.2 + 20 = 140, standard: 100 * 1 + 10 = 110
    assertEquals(0, res.getTotalAmount().compareTo(BigDecimal.valueOf(250)));
    assertEquals(2, res.getTickets().size());
    assertTrue(res.getTickets().stream().anyMatch(t -> t.getSeat().getId().equals(101L) && t.getTicketPrice().compareTo(BigDecimal.valueOf(140)) == 0));
    assertTrue(res.getTickets().stream().anyMatch(t -> t.getSeat().getId().equals(102L) && t.getTicketPrice().compareTo(BigDecimal.valueOf(110)) == 0));
    assertEquals(198, session.getAvailableSeats());
  }

  @Test
  void purchaseReservationAppliesPromotionAndConfirms() {
    Customer customer = new Customer();
    customer.setId(1L);
    customer.setMembershipStatus(MembershipStatus.REGULAR);

    Session session = new Session();
    session.setId(20L);
    session.setStartTime(LocalDateTime.now().plusDays(1));

    Ticket t1 = new Ticket();
    t1.setTicketPrice(BigDecimal.valueOf(100));
    Ticket t2 = new Ticket();
    t2.setTicketPrice(BigDecimal.valueOf(50));

    Reservation reservation = new Reservation();
    reservation.setId(5L);
    reservation.setCustomer(customer);
    reservation.setSession(session);
    reservation.setStatus(ReservationStatus.PENDING);
    reservation.setTickets(List.of(t1, t2));

    when(reservationRepository.findById(5L)).thenReturn(Optional.of(reservation));
    Promotion promo = new Promotion();
    promo.setDiscountAmount(BigDecimal.valueOf(30));
    ((StubPromotionService) promotionService).setPromo(promo);
    when(paymentRepository.save(any())).thenAnswer(invocation -> {
      Payment p = invocation.getArgument(0);
      p.setId(99L);
      return p;
    });
    when(reservationRepository.findByCustomerOrderByReservationDateDesc(customer)).thenReturn(List.of(reservation));
    when(reservationRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    Reservation updated = reservationService.purchaseReservation(5L, PaymentMethod.CREDIT_CARD, "PROMO");

    assertEquals(ReservationStatus.CONFIRMED, updated.getStatus());
    // 100 + 50 - 30 = 120
    assertEquals(0, updated.getTotalAmount().compareTo(BigDecimal.valueOf(120)));
    assertNotNull(updated.getPayment());
    assertEquals(0, updated.getPayment().getFinalAmount().compareTo(BigDecimal.valueOf(120)));
    assertEquals(MembershipStatus.REGULAR, updated.getCustomer().getMembershipStatus()); // thresholds not crossed

    ArgumentCaptor<Payment> paymentCaptor = ArgumentCaptor.forClass(Payment.class);
    verify(paymentRepository).save(paymentCaptor.capture());
    assertEquals(PaymentMethod.CREDIT_CARD, paymentCaptor.getValue().getPaymentMethod());
  }

  private static class StubPromotionService extends PromotionService {
    private Promotion promo;

    public StubPromotionService() {
      super(null);
    }

    @Override
    public Promotion validatePromotion(String code, BigDecimal totalAmount) {
      return promo;
    }

    public void setPromo(Promotion promo) {
      this.promo = promo;
    }
  }

  private static class NoopSessionService extends SessionService {
    public NoopSessionService() {
      super(null, null, null, null, null);
    }

    @Override
    public Session scheduleSession(Long movieId, Long hallId, LocalDateTime start, LocalDateTime end, double sessionPrice) {
      throw new UnsupportedOperationException();
    }

    @Override
    public void adjustAvailableSeats(Session session, int delta) {
      Integer current = session.getAvailableSeats();
      if (current == null) current = 0;
      session.setAvailableSeats(current + delta);
    }

    @Override
    public void recalcAvailableSeats(Session session) {
      // no-op for tests
    }

    @Override
    public java.util.List<SeatAvailability> getSeatAvailability(Long sessionId) {
      throw new UnsupportedOperationException();
    }
  }
}
