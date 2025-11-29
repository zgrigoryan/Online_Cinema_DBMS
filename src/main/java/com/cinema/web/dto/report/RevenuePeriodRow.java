package com.cinema.web.dto.report;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RevenuePeriodRow {
  private String paymentMethod;
  private boolean withPromotion;
  private BigDecimal total;
}
