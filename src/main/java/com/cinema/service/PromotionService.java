package com.cinema.service;

import com.cinema.domain.model.Promotion;
import com.cinema.repository.PromotionRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.springframework.stereotype.Service;

@Service
public class PromotionService {

  private final PromotionRepository promotionRepository;

  public PromotionService(PromotionRepository promotionRepository) {
    this.promotionRepository = promotionRepository;
  }

  public Promotion validatePromotion(String code, BigDecimal totalAmount) {
    Promotion promotion = promotionRepository.findActiveByCode(code, LocalDateTime.now())
        .orElseThrow(() -> new IllegalArgumentException("Invalid or inactive promotion"));
    return promotion;
  }
}
