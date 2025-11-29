package com.cinema.web.dto.report;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class TopCustomerRow {
  private Long customerId;
  private String name;
  private BigDecimal totalSpent;
  private Long reservationsCount;
  private Long ticketsCount;
}
