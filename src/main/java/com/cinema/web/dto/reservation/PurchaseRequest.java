package com.cinema.web.dto.reservation;

import com.cinema.domain.enums.PaymentMethod;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PurchaseRequest {
  @NotNull
  private PaymentMethod paymentMethod;
  private String promotionCode;
}
