package com.cinema.service;

import com.cinema.domain.enums.SessionStatus;
import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Session;
import com.cinema.repository.CinemaHallRepository;
import com.cinema.repository.MovieRepository;
import com.cinema.repository.SessionRepository;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SessionService {

  private final SessionRepository sessionRepository;
  private final MovieRepository movieRepository;
  private final CinemaHallRepository hallRepository;

  public SessionService(SessionRepository sessionRepository,
                        MovieRepository movieRepository,
                        CinemaHallRepository hallRepository) {
    this.sessionRepository = sessionRepository;
    this.movieRepository = movieRepository;
    this.hallRepository = hallRepository;
  }

  @Transactional
  public Session scheduleSession(Long movieId, Long hallId, OffsetDateTime start, OffsetDateTime end, double basePrice) {
    Movie movie = movieRepository.findById(movieId).orElseThrow(() -> new IllegalArgumentException("Movie not found"));
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
}
