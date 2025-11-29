package com.cinema.web.dto.report;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RevenueSessionRow {
  private Long sessionId;
  private LocalDate showDate;
  private LocalDateTime startTime;
  private String movieTitle;
  private String hallName;
  private BigDecimal revenue;
  private Long ticketsSold;
  private BigDecimal avgTicketPrice;
}
