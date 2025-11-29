package com.cinema.web.controller;

import com.cinema.domain.model.Session;
import com.cinema.service.SessionService;
import com.cinema.web.dto.session.SessionRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/sessions")
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminSessionController {

  private final SessionService sessionService;

  public AdminSessionController(SessionService sessionService) {
    this.sessionService = sessionService;
  }

  @PostMapping
  public ResponseEntity<Session> create(@Valid @RequestBody SessionRequest request) {
    Session session = sessionService.scheduleSession(
        request.getMovieId(), request.getHallId(), request.getStartTime(), request.getEndTime(), request.getSessionPrice());
    return ResponseEntity.ok(session);
  }
}
