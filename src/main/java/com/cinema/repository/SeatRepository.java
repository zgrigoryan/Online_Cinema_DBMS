package com.cinema.repository;

import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Seat;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SeatRepository extends JpaRepository<Seat, Long> {
  List<Seat> findByHall(CinemaHall hall);
}
