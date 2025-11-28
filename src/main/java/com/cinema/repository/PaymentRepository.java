package com.cinema.repository;

import com.cinema.domain.model.Payment;
import com.cinema.web.dto.report.RevenueRow;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

  @Query("SELECT new com.cinema.web.dto.report.RevenueRow(CAST(p.paidAt AS date), SUM(p.amount)) "
      + "FROM Payment p WHERE p.status = 'PAID' GROUP BY CAST(p.paidAt AS date) ORDER BY CAST(p.paidAt AS date) DESC")
  List<RevenueRow> revenueByDay();

  @Query("SELECT m.title, SUM(pay.amount) FROM Payment pay "
      + "JOIN Reservation r ON pay.reservation = r "
      + "JOIN Session s ON r.session = s "
      + "JOIN Movie m ON s.movie = m "
      + "WHERE pay.status = 'PAID' GROUP BY m.title ORDER BY SUM(pay.amount) DESC")
  List<Object[]> revenueByMovie();

  @Query("SELECT s.id, s.startTime, SUM(pay.amount) FROM Payment pay "
      + "JOIN Reservation r ON pay.reservation = r "
      + "JOIN Session s ON r.session = s "
      + "WHERE pay.status = 'PAID' GROUP BY s.id, s.startTime ORDER BY s.startTime DESC")
  List<Object[]> revenueBySession();
}
