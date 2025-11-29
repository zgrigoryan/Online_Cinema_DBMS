package com.cinema.web.dto.reservation;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class ReservationHistoryResponse {
  private Long reservationId;
  private String status;
  private LocalDateTime reservationDate;
  private BigDecimal totalAmount;
  private Long sessionId;
  private LocalDate showDate;
  private LocalTime startTime;
  private LocalTime endTime;
  private String movieTitle;
  private String hallName;
  private String promotionCode;
  private Long paymentId;
  private List<TicketInfo> tickets;

  @Getter
  @Setter
  @AllArgsConstructor
  public static class TicketInfo {
    private Integer row;
    private Integer number;
    private String category;
    private BigDecimal price;
  }
}
