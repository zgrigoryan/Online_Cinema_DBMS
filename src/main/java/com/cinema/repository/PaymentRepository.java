package com.cinema.repository;

import com.cinema.domain.model.Payment;
import com.cinema.web.dto.report.RevenueRow;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

  @Query("SELECT new com.cinema.web.dto.report.RevenueRow(CAST(p.paymentDate AS date), SUM(p.finalAmount)) "
      + "FROM Payment p GROUP BY CAST(p.paymentDate AS date) ORDER BY CAST(p.paymentDate AS date) DESC")
  List<RevenueRow> revenueByDay();

  @Query("SELECT m.title, SUM(pay.finalAmount) FROM Payment pay "
      + "JOIN pay.reservations r "
      + "JOIN Session s ON r.session = s "
      + "JOIN Movie m ON s.movie = m "
      + "GROUP BY m.title ORDER BY SUM(pay.finalAmount) DESC")
  List<Object[]> revenueByMovie();

  @Query("SELECT s.id, s.startTime, SUM(pay.finalAmount) FROM Payment pay "
      + "JOIN pay.reservations r "
      + "JOIN Session s ON r.session = s "
      + "GROUP BY s.id, s.startTime ORDER BY s.startTime DESC")
  List<Object[]> revenueBySession();
}
