package com.cinema.web.dto.movie;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MovieRequest {
  @NotBlank
  private String title;
  private String description;
  @Min(1)
  private int durationMinutes;
}
