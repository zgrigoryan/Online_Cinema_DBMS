package com.cinema.web.controller;

import com.cinema.domain.enums.SessionStatus;
import com.cinema.domain.model.Session;
import com.cinema.service.SessionService;
import com.cinema.repository.SessionRepository;
import com.cinema.web.dto.session.SessionRequest;
import jakarta.validation.Valid;
import java.time.OffsetDateTime;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/sessions")
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminSessionController {

  private final SessionService sessionService;
  private final SessionRepository sessionRepository;

  public AdminSessionController(SessionService sessionService, SessionRepository sessionRepository) {
    this.sessionService = sessionService;
    this.sessionRepository = sessionRepository;
  }

  @PostMapping
  public ResponseEntity<Session> create(@Valid @RequestBody SessionRequest request) {
    Session session = sessionService.scheduleSession(
        request.getMovieId(), request.getHallId(), request.getStartTime(), request.getEndTime(), request.getBasePrice());
    return ResponseEntity.ok(session);
  }

  @PatchMapping("/{id}/status")
  public ResponseEntity<Session> updateStatus(@PathVariable Long id, @RequestParam SessionStatus status) {
    Session session = sessionRepository.findById(id).orElseThrow();
    session.setStatus(status);
    session.setUpdatedAt(OffsetDateTime.now());
    return ResponseEntity.ok(sessionRepository.save(session));
  }
}
