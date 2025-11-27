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
}
