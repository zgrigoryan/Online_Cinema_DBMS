package com.cinema.web.dto.report;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PromotionEffectivenessRow {
  private Long promotionId;
  private String code;
  private Long timesUsed;
  private BigDecimal revenueWithPromo;
}
