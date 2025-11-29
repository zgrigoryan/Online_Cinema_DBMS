package com.cinema.web.dto.customer;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateProfileRequest {
  @NotBlank
  private String firstName;
  @NotBlank
  private String lastName;
  @NotBlank
  private String phone;
  @Email
  private String email;
}
