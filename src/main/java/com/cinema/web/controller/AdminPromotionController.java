package com.cinema.web.controller;

import com.cinema.domain.model.Promotion;
import com.cinema.repository.PromotionRepository;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
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
                                          @RequestParam @Min(0) @Max(100) double discountPercent,
                                          @RequestParam LocalDate validFrom,
                                          @RequestParam LocalDate validTo,
                                          @RequestParam(defaultValue = "0") double minAmount) {
    Promotion p = new Promotion();
    p.setCode(code);
    p.setDescription("Promo " + code);
    p.setDiscountPercent(java.math.BigDecimal.valueOf(discountPercent));
    p.setValidFrom(validFrom);
    p.setValidTo(validTo);
    p.setActive(true);
    p.setMinAmount(java.math.BigDecimal.valueOf(minAmount));
    return ResponseEntity.ok(promotionRepository.save(p));
  }

  @PatchMapping("/{id}/activate")
  public ResponseEntity<Promotion> activate(@PathVariable Long id, @RequestParam boolean active) {
    Promotion p = promotionRepository.findById(id).orElseThrow();
    p.setActive(active);
    return ResponseEntity.ok(promotionRepository.save(p));
  }
}
