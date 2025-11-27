package com.cinema.repository;

import com.cinema.domain.enums.SessionStatus;
import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Session;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SessionRepository extends JpaRepository<Session, Long> {

  List<Session> findByMovie(Movie movie);

  @Query("SELECT s FROM Session s WHERE (:movieId IS NULL OR s.movie.id = :movieId)")
  List<Session> findByMovieIdNullable(@Param("movieId") Long movieId);

  @Query("SELECT s FROM Session s WHERE s.hall = :hall AND s.status IN :statuses "
      + "AND s.startTime < :endTime AND s.endTime > :startTime")
  List<Session> findOverlappingSessions(@Param("hall") CinemaHall hall,
                                        @Param("startTime") OffsetDateTime startTime,
                                        @Param("endTime") OffsetDateTime endTime,
                                        @Param("statuses") List<SessionStatus> statuses);
}
