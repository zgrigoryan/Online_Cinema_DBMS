package com.cinema.repository;

import com.cinema.domain.model.Payment;
import com.cinema.domain.enums.PaymentMethod;
import com.cinema.web.dto.report.RevenueRow;
import com.cinema.web.dto.report.RevenuePeriodRow;
import com.cinema.web.dto.report.RevenueMovieRow;
import com.cinema.web.dto.report.RevenueSessionRow;
import com.cinema.web.dto.report.PromotionEffectivenessRow;
import com.cinema.web.dto.report.MoviePerformanceRow;
import com.cinema.web.dto.report.EmployeeWorkloadRow;
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

  @Query("SELECT new com.cinema.web.dto.report.RevenueMovieRow(m.id, m.title, "
      + "SUM(p.finalAmount), COUNT(t), AVG(t.ticketPrice)) "
      + "FROM Payment p "
      + "JOIN p.reservations r "
      + "JOIN Session s ON r.session = s "
      + "JOIN Movie m ON s.movie = m "
      + "LEFT JOIN r.tickets t "
      + "WHERE r.status = 'CONFIRMED' "
      + "GROUP BY m.id, m.title ORDER BY SUM(p.finalAmount) DESC")
  List<RevenueMovieRow> revenueMovieDetail();

  @Query("SELECT new com.cinema.web.dto.report.RevenueSessionRow(s.id, s.showDate, s.startTime, m.title, h.name, "
      + "SUM(p.finalAmount), COUNT(t), AVG(t.ticketPrice)) "
      + "FROM Payment p "
      + "JOIN p.reservations r "
      + "JOIN Session s ON r.session = s "
      + "JOIN Movie m ON s.movie = m "
      + "JOIN CinemaHall h ON s.hall = h "
      + "LEFT JOIN r.tickets t "
      + "WHERE r.status = 'CONFIRMED' "
      + "GROUP BY s.id, s.showDate, s.startTime, m.title, h.name "
      + "ORDER BY s.startTime DESC")
  List<RevenueSessionRow> revenueSessionDetail();

  @Query("SELECT new com.cinema.web.dto.report.PromotionEffectivenessRow(promo.id, promo.code, "
      + "COUNT(pay), SUM(pay.finalAmount)) "
      + "FROM Promotion promo "
      + "LEFT JOIN Payment pay ON pay.promotion = promo "
      + "GROUP BY promo.id, promo.code ORDER BY COUNT(pay) DESC")
  List<PromotionEffectivenessRow> promotionEffectiveness();

  @Query("SELECT new com.cinema.web.dto.report.MoviePerformanceRow(m.id, m.title, "
      + "COALESCE(SUM(pay.finalAmount),0), COUNT(t), COALESCE(AVG(rv.rating),0), COUNT(rv)) "
      + "FROM Movie m "
      + "LEFT JOIN Session s ON s.movie = m "
      + "LEFT JOIN Reservation r ON r.session = s "
      + "LEFT JOIN Payment pay ON pay = r.payment "
      + "LEFT JOIN Ticket t ON t.reservation = r "
      + "LEFT JOIN Review rv ON rv.movie = m "
      + "GROUP BY m.id, m.title ORDER BY COALESCE(SUM(pay.finalAmount),0) DESC")
  List<MoviePerformanceRow> moviePerformance();

  @Query("SELECT new com.cinema.web.dto.report.EmployeeWorkloadRow(e.id, CONCAT(p.firstName,' ',p.lastName), s.showDate, COUNT(mn.session)) "
      + "FROM Monitors mn "
      + "JOIN mn.employee e "
      + "JOIN Person p ON p.id = e.id "
      + "JOIN mn.session s "
      + "GROUP BY e.id, p.firstName, p.lastName, s.showDate "
      + "ORDER BY s.showDate DESC")
  List<EmployeeWorkloadRow> employeeWorkload();
}
