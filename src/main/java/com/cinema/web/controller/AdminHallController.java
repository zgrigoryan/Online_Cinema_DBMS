package com.cinema.web.controller;

import com.cinema.domain.enums.HallType;
import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Seat;
import com.cinema.repository.CinemaHallRepository;
import com.cinema.repository.SeatRepository;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/halls")
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminHallController {

  private final CinemaHallRepository hallRepository;
  private final SeatRepository seatRepository;

  public AdminHallController(CinemaHallRepository hallRepository, SeatRepository seatRepository) {
    this.hallRepository = hallRepository;
    this.seatRepository = seatRepository;
  }

  @GetMapping
  public List<CinemaHall> listHalls() {
    return hallRepository.findAll();
  }

  @PostMapping
  public ResponseEntity<CinemaHall> createHall(@RequestParam @NotBlank String name,
                                               @RequestParam @Min(1) Integer capacity,
                                               @RequestParam(defaultValue = "REGULAR") HallType type) {
    CinemaHall hall = new CinemaHall();
    hall.setName(name);
    hall.setCapacity(capacity);
    hall.setType(type);
    return ResponseEntity.ok(hallRepository.save(hall));
  }

  @GetMapping("/{hallId}/seats")
  public List<Seat> listSeats(@PathVariable Long hallId) {
    CinemaHall hall = hallRepository.findById(hallId).orElseThrow();
    return seatRepository.findByHall(hall);
  }

  @PostMapping("/{hallId}/seats")
  public ResponseEntity<Seat> addSeat(@PathVariable Long hallId,
                                      @RequestParam @Min(1) Integer row,
                                      @RequestParam @Min(1) Integer number,
                                      @RequestParam @Min(0) Double basePrice,
                                      @RequestParam(defaultValue = "Standard") String category) {
    CinemaHall hall = hallRepository.findById(hallId).orElseThrow();
    long currentSeats = seatRepository.countByHall(hall);
    if (currentSeats >= hall.getCapacity()) {
      return ResponseEntity.badRequest().build();
    }
    Seat seat = new Seat();
    seat.setHall(hall);
    seat.setRowNumber(row);
    seat.setSeatNumber(number);
    seat.setBasePrice(BigDecimal.valueOf(basePrice));
    seat.setCategory(category);
    return ResponseEntity.ok(seatRepository.save(seat));
  }
}
