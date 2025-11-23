package com.cinema.web.controller;

import com.cinema.domain.enums.Role;
import com.cinema.domain.model.Person;
import com.cinema.domain.model.Reservation;
import com.cinema.service.ReservationService;
import com.cinema.web.dto.reservation.ReservationRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

  private final ReservationService reservationService;

  public ReservationController(ReservationService reservationService) {
    this.reservationService = reservationService;
  }

  @PostMapping
  @PreAuthorize("hasRole('CUSTOMER')")
  public ResponseEntity<Reservation> create(@AuthenticationPrincipal Person person,
                                            @Valid @RequestBody ReservationRequest request) {
    if (person.getRole() != Role.CUSTOMER) {
      return ResponseEntity.status(403).build();
    }
    Reservation reservation = reservationService.createReservation(
        person.getId(), request.getSessionId(), request.getSeatIds(), request.getPromotionCode());
    return ResponseEntity.ok(reservation);
  }
}
