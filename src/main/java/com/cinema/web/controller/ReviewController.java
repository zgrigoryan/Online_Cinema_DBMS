package com.cinema.web.controller;

import com.cinema.domain.enums.Role;
import com.cinema.domain.model.Person;
import com.cinema.domain.model.Review;
import com.cinema.service.ReviewService;
import com.cinema.web.dto.review.ReviewRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

  private final ReviewService reviewService;

  public ReviewController(ReviewService reviewService) {
    this.reviewService = reviewService;
  }

  @PostMapping
  @PreAuthorize("hasRole('CUSTOMER')")
  public ResponseEntity<Review> upsert(@AuthenticationPrincipal Person person,
                                       @Valid @RequestBody ReviewRequest request) {
    if (person.getRole() != Role.CUSTOMER) {
      return ResponseEntity.status(403).build();
    }
    Review review = reviewService.addOrUpdateReview(person.getId(), request.getMovieId(),
        request.getRating(), request.getComment());
    return ResponseEntity.ok(review);
  }
}
