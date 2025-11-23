package com.cinema.web.controller;

import com.cinema.domain.model.Movie;
import com.cinema.repository.MovieRepository;
import com.cinema.web.dto.movie.MovieRequest;
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
@RequestMapping("/api/movies")
public class MovieController {

  private final MovieRepository movieRepository;

  public MovieController(MovieRepository movieRepository) {
    this.movieRepository = movieRepository;
  }

  @GetMapping
  public List<Movie> list() {
    return movieRepository.findAll();
  }

  @GetMapping("/{id}")
  public Movie get(@PathVariable Long id) {
    return movieRepository.findById(id).orElseThrow();
  }

  @PostMapping
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<Movie> create(@Valid @RequestBody MovieRequest request) {
    Movie movie = new Movie();
    movie.setTitle(request.getTitle());
    movie.setDescription(request.getDescription());
    movie.setDurationMinutes(request.getDurationMinutes());
    Movie saved = movieRepository.save(movie);
    return ResponseEntity.ok(saved);
  }
}
