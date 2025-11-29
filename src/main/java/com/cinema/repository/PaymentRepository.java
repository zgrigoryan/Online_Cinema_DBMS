package com.cinema.repository;

import com.cinema.domain.model.Payment;
import com.cinema.domain.enums.PaymentMethod;
import com.cinema.web.dto.report.RevenueRow;
import com.cinema.web.dto.report.RevenuePeriodRow;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;

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

  @Query("SELECT new com.cinema.web.dto.report.RevenuePeriodRow("
      + "COALESCE(CAST(p.paymentMethod AS string),'ALL'), "
      + "(p.promotion IS NOT NULL), "
      + "SUM(p.finalAmount)) "
      + "FROM Payment p "
      + "WHERE (:start IS NULL OR p.paymentDate >= :start) "
      + "AND (:end IS NULL OR p.paymentDate <= :end) "
      + "AND (:method IS NULL OR p.paymentMethod = :method) "
      + "AND (:promoOnly = false OR p.promotion IS NOT NULL) "
      + "GROUP BY p.paymentMethod, (p.promotion IS NOT NULL)")
  List<RevenuePeriodRow> revenueByPeriod(@Param("start") LocalDateTime start,
                                         @Param("end") LocalDateTime end,
                                         @Param("method") PaymentMethod method,
                                         @Param("promoOnly") boolean promoOnly);
}
