package com.cinema.web.controller;

import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Session;
import com.cinema.domain.enums.PaymentMethod;
import com.cinema.repository.PaymentRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.web.dto.report.OccupancyRow;
import com.cinema.web.dto.report.RevenueRow;
import com.cinema.web.dto.report.RevenuePeriodRow;
import com.cinema.web.dto.report.RevenueMovieRow;
import com.cinema.web.dto.report.RevenueSessionRow;
import com.cinema.web.dto.report.TopCustomerRow;
import com.cinema.web.dto.report.PromotionEffectivenessRow;
import com.cinema.web.dto.report.MoviePerformanceRow;
import com.cinema.web.dto.report.EmployeeWorkloadRow;
import com.cinema.web.dto.report.CancellationStatsRow;
import java.util.List;
import java.time.LocalDateTime;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

  private final PaymentRepository paymentRepository;
  private final SessionRepository sessionRepository;

  public ReportController(PaymentRepository paymentRepository,
                          SessionRepository sessionRepository) {
    this.paymentRepository = paymentRepository;
    this.sessionRepository = sessionRepository;
  }
  @GetMapping("/revenue/daily")
  public ResponseEntity<List<RevenueRow>> revenueDaily() {
    List<RevenueRow> rows = paymentRepository.revenueByDay();
    return ResponseEntity.ok(rows);
  }

  @GetMapping("/revenue/period")
  public ResponseEntity<List<RevenuePeriodRow>> revenueByPeriod(
      @RequestParam(required = false) LocalDateTime start,
      @RequestParam(required = false) LocalDateTime end,
      @RequestParam(required = false) PaymentMethod paymentMethod,
      @RequestParam(defaultValue = "false") boolean promoOnly) {
    return ResponseEntity.ok(paymentRepository.revenueByPeriod(start, end, paymentMethod, promoOnly));
  }

  @GetMapping("/revenue/movie")
  public ResponseEntity<List<RevenueMovieRow>> revenueByMovie() {
    return ResponseEntity.ok(paymentRepository.revenueMovieDetail());
  }

  @GetMapping("/revenue/session")
  public ResponseEntity<List<RevenueSessionRow>> revenueBySession() {
    return ResponseEntity.ok(paymentRepository.revenueSessionDetail());
  }

  @GetMapping("/customers/top")
  public ResponseEntity<List<TopCustomerRow>> topCustomers() {
    return ResponseEntity.ok(reservationRepository.topCustomers());
  }

  @GetMapping("/promotions/effectiveness")
  public ResponseEntity<List<PromotionEffectivenessRow>> promotionEffectiveness() {
    return ResponseEntity.ok(paymentRepository.promotionEffectiveness());
  }

  @GetMapping("/movies/performance")
  public ResponseEntity<List<MoviePerformanceRow>> moviePerformance() {
    return ResponseEntity.ok(paymentRepository.moviePerformance());
  }

  @GetMapping("/employees/workload")
  public ResponseEntity<List<EmployeeWorkloadRow>> employeeWorkload() {
    return ResponseEntity.ok(paymentRepository.employeeWorkload());
  }

  @GetMapping("/cancellations")
  public ResponseEntity<List<CancellationStatsRow>> cancellations() {
    return ResponseEntity.ok(reservationRepository.cancellationStats());
  }

  @GetMapping("/occupancy")
  public ResponseEntity<List<OccupancyRow>> occupancy() {
    List<Session> sessions = sessionRepository.findAll();
    List<OccupancyRow> rows = sessions.stream().map(s -> {
      CinemaHall hall = s.getHall();
      int seatsSold = hall.getCapacity() - s.getAvailableSeats();
      double pct = hall.getCapacity() == 0 ? 0d : (double) seatsSold / hall.getCapacity() * 100;
      return new OccupancyRow(s.getId(), s.getMovie().getTitle(), hall.getName(),
          hall.getCapacity(), seatsSold, Math.round(pct * 100.0) / 100.0);
    }).toList();
    return ResponseEntity.ok(rows);
  }
}
