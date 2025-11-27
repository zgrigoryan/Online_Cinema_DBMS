package com.cinema.service;

import com.cinema.domain.enums.SessionStatus;
import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Session;
import com.cinema.repository.CinemaHallRepository;
import com.cinema.repository.MovieRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.repository.SeatRepository;
import com.cinema.repository.TicketRepository;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SessionService {

  private final SessionRepository sessionRepository;
  private final MovieRepository movieRepository;
  private final CinemaHallRepository hallRepository;
  private final SeatRepository seatRepository;
  private final TicketRepository ticketRepository;

  public SessionService(SessionRepository sessionRepository,
                        MovieRepository movieRepository,
                        CinemaHallRepository hallRepository,
                        SeatRepository seatRepository,
                        TicketRepository ticketRepository) {
    this.sessionRepository = sessionRepository;
    this.movieRepository = movieRepository;
    this.hallRepository = hallRepository;
    this.seatRepository = seatRepository;
    this.ticketRepository = ticketRepository;
  }

  @Transactional
  public Session scheduleSession(Long movieId, Long hallId, OffsetDateTime start, OffsetDateTime end, double basePrice) {
    if (movieId == null) {
      throw new IllegalArgumentException("Movie ID cannot be null");
    }
    Movie movie = movieRepository.findById(movieId).orElseThrow(() -> new IllegalArgumentException("Movie not found"));
    if (hallId == null) {
      throw new IllegalArgumentException("Hall ID cannot be null");
    }
    CinemaHall hall = hallRepository.findById(hallId).orElseThrow(() -> new IllegalArgumentException("Hall not found"));
    List<Session> overlaps = sessionRepository.findOverlappingSessions(
        hall, start, end, List.of(SessionStatus.SCHEDULED, SessionStatus.ACTIVE));
    if (!overlaps.isEmpty()) {
      throw new IllegalStateException("Session overlaps with another session in the same hall");
    }
    Session session = new Session();
    session.setMovie(movie);
    session.setHall(hall);
    session.setStartTime(start);
    session.setEndTime(end);
    session.setBasePrice(basePrice);
    session.setStatus(SessionStatus.SCHEDULED);
    session.setAvailableSeats(hall.getCapacity());
    return sessionRepository.save(session);
  }

  @Transactional
  public void adjustAvailableSeats(Session session, int delta) {
    int updated = session.getAvailableSeats() + delta;
    if (updated < 0) {
      throw new IllegalStateException("Not enough seats available");
    }
    session.setAvailableSeats(updated);
    sessionRepository.save(session);
  }

  @Transactional(readOnly = true)
  public List<com.cinema.web.dto.session.SeatAvailability> getSeatAvailability(Long sessionId) {
    if (sessionId == null) {
      throw new IllegalArgumentException("Session ID cannot be null");
    }
    Session session = sessionRepository.findById(sessionId)
        .orElseThrow(() -> new IllegalArgumentException("Session not found"));
    var tickets = ticketRepository.findBySession(session);
    var seats = seatRepository.findByHall(session.getHall());
    return seats.stream()
        .map(seat -> {
          boolean booked = tickets.stream().anyMatch(t -> t.getSeat().getId().equals(seat.getId())
              && t.getStatus().name().equals("ACTIVE"));
          return new com.cinema.web.dto.session.SeatAvailability(
              seat.getId(), seat.getLabel(), seat.getSeatRow(), seat.getSeatNumber(),
              booked ? "BOOKED" : "AVAILABLE");
        })
        .toList();
  }
}
