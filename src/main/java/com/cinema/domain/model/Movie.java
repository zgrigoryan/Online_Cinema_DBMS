package com.cinema.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "movie")
public class Movie {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "movie_id")
  private Long id;

  @Column(nullable = false, unique = true, length = 255)
  private String title;

  @Column(columnDefinition = "TEXT")
  private String description;

  @Column(nullable = false, length = 100)
  private String genre = "Unknown";

  @Column(name = "duration", nullable = false)
  private Integer durationMinutes;

  @Column(name = "release_year")
  private LocalDate releaseYear;

  @Column(name = "movie_rating", precision = 10, scale = 2)
  private BigDecimal movieRating;
}
