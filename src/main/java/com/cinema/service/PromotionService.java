package com.cinema.service;

import com.cinema.domain.model.Promotion;
import com.cinema.repository.PromotionRepository;
import java.time.LocalDate;
import org.springframework.stereotype.Service;

@Service
public class PromotionService {

  private final PromotionRepository promotionRepository;

  public PromotionService(PromotionRepository promotionRepository) {
    this.promotionRepository = promotionRepository;
  }

  public Promotion validatePromotion(String code, double totalAmount) {
    Promotion promotion = promotionRepository.findActiveByCode(code, LocalDate.now())
        .orElseThrow(() -> new IllegalArgumentException("Invalid or inactive promotion"));
    if (promotion.getUsageLimit() != null && promotion.getTimesRedeemed() >= promotion.getUsageLimit()) {
      throw new IllegalStateException("Promotion usage limit reached");
    }
    if (totalAmount < promotion.getMinAmount()) {
      throw new IllegalStateException("Total amount below promotion minimum");
    }
    return promotion;
  }
}
