package com.cinema.web.dto.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class OccupancyRow {
  private Long sessionId;
  private String movieTitle;
  private String hallName;
  private Integer capacity;
  private Integer seatsSold;
  private Double occupancyPct;
}
