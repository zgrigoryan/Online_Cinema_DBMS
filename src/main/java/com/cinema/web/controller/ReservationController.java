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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import java.util.Objects;

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
    Long personId = person.getId();
    if (personId == null || request.getSessionId() == null || request.getSeatIds() == null || request.getSeatIds().isEmpty()) {
      return ResponseEntity.badRequest().build();
    }
    Long sessionId = Objects.requireNonNull(request.getSessionId(), "Session ID cannot be null");
    var seatIds = Objects.requireNonNull(request.getSeatIds(), "Seat IDs cannot be null");
    Reservation reservation = reservationService.createReservation(
        Objects.requireNonNull(personId, "Person ID cannot be null"),
        sessionId,
        seatIds,
        request.getPromotionCode());
    return ResponseEntity.ok(reservation);
  }

  @PostMapping("/cancel/{id}")
  @PreAuthorize("hasRole('CUSTOMER')")
  public ResponseEntity<Reservation> cancel(@AuthenticationPrincipal Person person,
                                            @PathVariable Long id) {
    if (person.getRole() != Role.CUSTOMER) {
      return ResponseEntity.status(403).build();
    }
    Reservation reservation = reservationService.cancelReservation(id, person.getId());
    return ResponseEntity.ok(reservation);
  }

  @GetMapping("/history")
  @PreAuthorize("hasRole('CUSTOMER')")
  public ResponseEntity<?> history(@AuthenticationPrincipal Person person) {
    if (person.getRole() != Role.CUSTOMER) {
      return ResponseEntity.status(403).build();
    }
    return ResponseEntity.ok(reservationService.getHistory(person.getId()));
  }
}
