package com.cinema.web.controller;

import com.cinema.domain.model.Movie;
import com.cinema.repository.MovieRepository;
import com.cinema.web.dto.movie.MovieRequest;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/movies")
@PreAuthorize("hasRole('ADMIN')")
public class AdminMovieController {

  private final MovieRepository movieRepository;

  public AdminMovieController(MovieRepository movieRepository) {
    this.movieRepository = movieRepository;
  }

  @GetMapping
  public List<Movie> list() {
    return movieRepository.findAll();
  }

  @PostMapping
  public ResponseEntity<Movie> create(@Valid @RequestBody MovieRequest request) {
    Movie movie = new Movie();
    movie.setTitle(request.getTitle());
    movie.setDescription(request.getDescription());
    movie.setDurationMinutes(request.getDurationMinutes());
    movie.setReleaseYear(null);
    Movie saved = movieRepository.save(movie);
    return ResponseEntity.ok(saved);
  }

  @PutMapping("/{id}")
  public ResponseEntity<Movie> update(@PathVariable Long id, @Valid @RequestBody MovieRequest request) {
    Movie movie = movieRepository.findById(id).orElseThrow();
    movie.setTitle(request.getTitle());
    movie.setDescription(request.getDescription());
    movie.setDurationMinutes(request.getDurationMinutes());
    return ResponseEntity.ok(movieRepository.save(movie));
  }
}
