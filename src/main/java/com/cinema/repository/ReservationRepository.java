package com.cinema.repository;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Reservation;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
  boolean existsByCustomer(Customer customer);

  List<Reservation> findByCustomerOrderByReservationDateDesc(Customer customer);

  @Query("SELECT new com.cinema.web.dto.report.TopCustomerRow(c.id, CONCAT(p.firstName,' ',p.lastName), "
      + "SUM(r.totalAmount), COUNT(r), "
      + "(SELECT COUNT(t2) FROM Ticket t2 WHERE t2.reservation.customer = c)) "
      + "FROM Reservation r "
      + "JOIN r.customer c "
      + "JOIN Person p ON p.id = c.id "
      + "WHERE r.status = 'CONFIRMED' "
      + "GROUP BY c.id, p.firstName, p.lastName "
      + "ORDER BY SUM(r.totalAmount) DESC")
  List<com.cinema.web.dto.report.TopCustomerRow> topCustomers();

  @Query("SELECT new com.cinema.web.dto.report.CancellationStatsRow(s.id, m.title, "
      + "SUM(CASE WHEN r.status = 'CANCELLED' THEN 1 ELSE 0 END), "
      + "SUM(CASE WHEN r.status = 'CANCELLED' THEN r.totalAmount ELSE 0 END)) "
      + "FROM Reservation r "
      + "JOIN r.session s "
      + "JOIN s.movie m "
      + "GROUP BY s.id, m.title "
      + "HAVING SUM(CASE WHEN r.status = 'CANCELLED' THEN 1 ELSE 0 END) > 0 "
      + "ORDER BY s.startTime DESC")
  List<com.cinema.web.dto.report.CancellationStatsRow> cancellationStats();
}
