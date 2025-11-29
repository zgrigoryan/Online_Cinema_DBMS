package com.cinema.service;

import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Session;
import com.cinema.repository.CinemaHallRepository;
import com.cinema.repository.MovieRepository;
import com.cinema.repository.SessionRepository;
import com.cinema.repository.SeatRepository;
import com.cinema.repository.TicketRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.time.Duration;
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
  public static final Map<String, BigDecimal> CATEGORY_MULTIPLIER = Map.of(
      "VIP", BigDecimal.valueOf(1.2),
      "STANDARD", BigDecimal.ONE
  );
  private static final long MIN_GAP_MINUTES = 10;

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
  public Session scheduleSession(Long movieId, Long hallId, LocalDateTime start, LocalDateTime end, double sessionPrice) {
    if (movieId == null) {
      throw new IllegalArgumentException("Movie ID cannot be null");
    }
    Movie movie = movieRepository.findById(movieId).orElseThrow(() -> new IllegalArgumentException("Movie not found"));
    if (hallId == null) {
      throw new IllegalArgumentException("Hall ID cannot be null");
    }
    CinemaHall hall = hallRepository.findById(hallId).orElseThrow(() -> new IllegalArgumentException("Hall not found"));
    LocalDateTime bufferedStart = start.minusMinutes(MIN_GAP_MINUTES);
    LocalDateTime bufferedEnd = end.plusMinutes(MIN_GAP_MINUTES);
    List<Session> overlaps = sessionRepository.findOverlappingSessions(hall, bufferedStart, bufferedEnd);
    if (!overlaps.isEmpty()) {
      throw new IllegalStateException("Session overlaps with another session in the same hall");
    }
    Session session = new Session();
    session.setMovie(movie);
    session.setHall(hall);
    session.setStartTime(start);
    session.setEndTime(end);
    session.setSessionPrice(java.math.BigDecimal.valueOf(sessionPrice));
    session.setAvailableSeats(hall.getCapacity());
    session.setShowDate(start.toLocalDate());
    return sessionRepository.save(session);
  }

  @Transactional
  public void deleteSession(Long sessionId) {
    if (sessionId == null) {
      throw new IllegalArgumentException("Session ID cannot be null");
    }
    Session session = sessionRepository.findById(sessionId)
        .orElseThrow(() -> new IllegalArgumentException("Session not found"));
    if (session.getStartTime().isBefore(LocalDateTime.now())) {
      throw new IllegalStateException("Cannot delete sessions that have started");
    }
    sessionRepository.delete(session);
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
    var tickets = ticketRepository.findByReservation_Session(session);
    var seats = seatRepository.findByHall(session.getHall());
    return seats.stream()
        .map(seat -> {
          boolean booked = tickets.stream().anyMatch(t -> t.getSeat().getId().equals(seat.getId())
              );
          BigDecimal base = seat.getBasePrice() != null ? seat.getBasePrice() : BigDecimal.ZERO;
          BigDecimal multiplier = CATEGORY_MULTIPLIER.getOrDefault(
              seat.getCategory() != null ? seat.getCategory().toUpperCase() : "STANDARD",
              BigDecimal.ONE);
          BigDecimal price = session.getSessionPrice().multiply(multiplier).add(base);
          return new com.cinema.web.dto.session.SeatAvailability(
              seat.getId(),
              seat.getRowNumber() + "-" + seat.getSeatNumber(),
              seat.getRowNumber(),
              seat.getSeatNumber(),
              booked ? "BOOKED" : "AVAILABLE",
              price);
        })
        .toList();
  }
}
