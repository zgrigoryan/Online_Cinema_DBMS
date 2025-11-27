package com.cinema.web.dto.report;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RevenueRow {
  private LocalDate day;
  private Double revenue;
}
