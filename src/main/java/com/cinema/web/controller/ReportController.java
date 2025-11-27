package com.cinema.web.controller;

import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Session;
import com.cinema.repository.PaymentRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.web.dto.report.OccupancyRow;
import com.cinema.web.dto.report.RevenueRow;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
