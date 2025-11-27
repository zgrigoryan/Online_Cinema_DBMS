package com.cinema.web.controller;

import com.cinema.domain.model.Promotion;
import com.cinema.service.PromotionService;
import com.cinema.repository.PromotionRepository;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/promotions")
public class PromotionController {

  private final PromotionRepository promotionRepository;
  private final PromotionService promotionService;

  public PromotionController(PromotionRepository promotionRepository, PromotionService promotionService) {
    this.promotionRepository = promotionRepository;
    this.promotionService = promotionService;
  }

  @GetMapping
  public List<Promotion> list() {
    return promotionRepository.findAll();
  }

  @GetMapping("/validate/{code}")
  public ResponseEntity<Promotion> validate(@PathVariable String code) {
    Promotion promo = promotionService.validatePromotion(code, BigDecimal.ZERO);
    return ResponseEntity.ok(promo);
  }
}
