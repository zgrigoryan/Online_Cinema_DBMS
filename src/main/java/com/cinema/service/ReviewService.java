package com.cinema.service;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Review;
import com.cinema.domain.model.Ticket;
import com.cinema.repository.CustomerRepository;
import com.cinema.repository.MovieRepository;
import com.cinema.repository.ReviewRepository;
import com.cinema.repository.TicketRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReviewService {

  private final ReviewRepository reviewRepository;
  private final CustomerRepository customerRepository;
  private final MovieRepository movieRepository;
  private final TicketRepository ticketRepository;

  public ReviewService(ReviewRepository reviewRepository,
                       CustomerRepository customerRepository,
                       MovieRepository movieRepository,
                       TicketRepository ticketRepository) {
    this.reviewRepository = reviewRepository;
    this.customerRepository = customerRepository;
    this.movieRepository = movieRepository;
    this.ticketRepository = ticketRepository;
  }

  @Transactional
  public Review addOrUpdateReview(Long customerId, Long movieId, int rating, String comment) {
    if (customerId == null) {
      throw new IllegalArgumentException("Customer ID must not be null");
    }
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    if (movieId == null) {
      throw new IllegalArgumentException("Movie ID must not be null");
    }
    Movie movie = movieRepository.findById(movieId)
        .orElseThrow(() -> new IllegalArgumentException("Movie not found"));

    validateEligibility(customer, movie);

    Review review = reviewRepository.findByCustomerAndMovie(customer, movie)
        .orElseGet(Review::new);
    review.setCustomer(customer);
    review.setMovie(movie);
    review.setRating(rating);
    review.setComment(comment);
    review.setReviewDate(LocalDateTime.now());
    Review saved = reviewRepository.save(review);
    Double avg = reviewRepository.averageRatingForMovie(movie);
    BigDecimal avgRating = avg != null ? BigDecimal.valueOf(avg) : BigDecimal.ZERO;
    movie.setMovieRating(avgRating);
    movieRepository.save(movie);
    return saved;
  }

  private void validateEligibility(Customer customer, Movie movie) {
    List<Ticket> tickets = ticketRepository.findByReservation_Customer_Id(customer.getId()).stream()
        .filter(ticket -> ticket.getReservation().getSession().getMovie().getId().equals(movie.getId()))
        .toList();
    boolean anyPast = tickets.stream().anyMatch(t -> t.getReservation().getSession().getEndTime().isBefore(LocalDateTime.now()));
    if (!anyPast) {
      throw new IllegalStateException("Customer must have attended a past session to review");
    }
  }
}
