package com.cinema.web.dto.reservation;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReservationRequest {

  @NotNull
  private Long sessionId;

  @NotEmpty
  private List<Long> seatIds;

  private String promotionCode;
}
