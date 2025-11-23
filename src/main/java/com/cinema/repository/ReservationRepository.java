package com.cinema.repository;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
  boolean existsByCustomer(Customer customer);
}
