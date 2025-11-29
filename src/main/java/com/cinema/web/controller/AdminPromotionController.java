package com.cinema.web.controller;

import com.cinema.domain.model.Promotion;
import com.cinema.repository.PromotionRepository;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/promotions")
@PreAuthorize("hasRole('ADMIN')")
public class AdminPromotionController {

  private final PromotionRepository promotionRepository;

  public AdminPromotionController(PromotionRepository promotionRepository) {
    this.promotionRepository = promotionRepository;
  }

  @GetMapping
  public List<Promotion> list() {
    return promotionRepository.findAll();
  }

  @PostMapping
  public ResponseEntity<Promotion> create(@RequestParam @NotBlank String code,
                                          @RequestParam @Min(0) double discountAmount,
                                          @RequestParam LocalDateTime startDate,
                                          @RequestParam LocalDateTime endDate) {
    Promotion p = new Promotion();
    p.setCode(code);
    p.setDiscountAmount(java.math.BigDecimal.valueOf(discountAmount));
    p.setStartDate(startDate);
    p.setEndDate(endDate);
    return ResponseEntity.ok(promotionRepository.save(p));
  }
}
