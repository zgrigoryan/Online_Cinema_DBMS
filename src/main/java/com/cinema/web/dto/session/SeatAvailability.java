package com.cinema.web.dto.session;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class SeatAvailability {
  private Long seatId;
  private String label;
  private Integer row;
  private Integer number;
  private String status;
}
