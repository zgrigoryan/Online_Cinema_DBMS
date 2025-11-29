package com.cinema.repository;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Review;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ReviewRepository extends JpaRepository<Review, Long> {

  Optional<Review> findByCustomerAndMovie(Customer customer, Movie movie);

  @Query("SELECT AVG(r.rating) FROM Review r WHERE r.movie = :movie")
  Double averageRatingForMovie(Movie movie);

  @Query("SELECT COUNT(r) FROM Review r WHERE r.movie = :movie")
  Long countByMovie(Movie movie);
}
