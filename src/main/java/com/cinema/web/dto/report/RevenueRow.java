package com.cinema.web.dto.report;

import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RevenueRow {
  private LocalDate day;
  private BigDecimal revenue;
}
