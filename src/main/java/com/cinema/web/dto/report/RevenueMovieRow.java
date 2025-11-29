package com.cinema.web.dto.report;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RevenueMovieRow {
  private Long movieId;
  private String title;
  private BigDecimal revenue;
  private Long ticketsSold;
  private BigDecimal avgTicketPrice;
}
