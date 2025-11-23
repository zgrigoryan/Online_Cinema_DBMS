package com.cinema.web.dto.session;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SessionRequest {

  @NotNull
  private Long movieId;

  @NotNull
  private Long hallId;

  @NotNull
  @Future
  private OffsetDateTime startTime;

  @NotNull
  @Future
  private OffsetDateTime endTime;

  @NotNull
  private Double basePrice;
}
