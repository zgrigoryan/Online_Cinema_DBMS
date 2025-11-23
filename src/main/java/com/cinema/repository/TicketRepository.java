package com.cinema.repository;

import com.cinema.domain.model.Seat;
import com.cinema.domain.model.Session;
import com.cinema.domain.model.Ticket;
import com.cinema.domain.model.TicketId;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketRepository extends JpaRepository<Ticket, TicketId> {
  boolean existsBySessionAndSeat(Session session, Seat seat);

  List<Ticket> findBySession(Session session);

  List<Ticket> findByReservation_Customer_Id(Long customerId);
}
