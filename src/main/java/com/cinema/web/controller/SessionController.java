package com.cinema.web.controller;

import com.cinema.domain.model.Session;
import com.cinema.repository.SessionRepository;
import com.cinema.service.SessionService;
import com.cinema.web.dto.session.SessionRequest;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sessions")
public class SessionController {

  private final SessionService sessionService;
  private final SessionRepository sessionRepository;

  public SessionController(SessionService sessionService, SessionRepository sessionRepository) {
    this.sessionService = sessionService;
    this.sessionRepository = sessionRepository;
  }

  @GetMapping
  public List<Session> list() {
    return sessionRepository.findAll();
  }

  @PostMapping
  @PreAuthorize("hasAnyRole('ADMIN','STAFF')")
  public ResponseEntity<Session> create(@Valid @RequestBody SessionRequest request) {
    Session session = sessionService.scheduleSession(
        request.getMovieId(), request.getHallId(), request.getStartTime(), request.getEndTime(), request.getBasePrice());
    return ResponseEntity.ok(session);
  }

  @GetMapping("/{id}")
  public Session get(@PathVariable Long id) {
    return sessionRepository.findById(id).orElseThrow();
  }
}
