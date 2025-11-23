package com.cinema.service;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Movie;
import com.cinema.domain.model.Review;
import com.cinema.domain.model.Ticket;
import com.cinema.repository.CustomerRepository;
import com.cinema.repository.MovieRepository;
import com.cinema.repository.ReviewRepository;
import com.cinema.repository.TicketRepository;
import java.time.OffsetDateTime;
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
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    Movie movie = movieRepository.findById(movieId)
        .orElseThrow(() -> new IllegalArgumentException("Movie not found"));

    validateEligibility(customer, movie);

    Review review = reviewRepository.findByCustomerAndMovie(customer, movie)
        .orElseGet(Review::new);
    review.setCustomer(customer);
    review.setMovie(movie);
    review.setRating(rating);
    review.setComment(comment);
    review.setUpdatedAt(OffsetDateTime.now());
    if (review.getCreatedAt() == null) {
      review.setCreatedAt(OffsetDateTime.now());
    }
    Review saved = reviewRepository.save(review);
    Double avg = reviewRepository.averageRatingForMovie(movie);
    movie.setAvgRating(avg != null ? avg : 0d);
    movieRepository.save(movie);
    return saved;
  }

  private void validateEligibility(Customer customer, Movie movie) {
    List<Ticket> tickets = ticketRepository.findByReservation_Customer_Id(customer.getId()).stream()
        .filter(ticket -> ticket.getSession().getMovie().getId().equals(movie.getId()))
        .toList();
    boolean anyPast = tickets.stream().anyMatch(t -> t.getSession().getEndTime().isBefore(OffsetDateTime.now()));
    if (!anyPast) {
      throw new IllegalStateException("Customer must have attended a past session to review");
    }
  }
}
