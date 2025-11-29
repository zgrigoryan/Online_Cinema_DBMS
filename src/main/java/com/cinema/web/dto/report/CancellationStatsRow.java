package com.cinema.web.dto.report;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CancellationStatsRow {
  private Long sessionId;
  private String movieTitle;
  private Long cancelledReservations;
  private BigDecimal cancelledAmount;
}
