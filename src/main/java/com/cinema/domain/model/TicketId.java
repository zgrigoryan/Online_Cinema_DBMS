package com.cinema.domain.model;

import java.io.Serializable;
import java.util.Objects;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class TicketId implements Serializable {
  private Long reservation;
  private Integer ticketNumber;

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    TicketId ticketId = (TicketId) o;
    return Objects.equals(reservation, ticketId.reservation)
        && Objects.equals(ticketNumber, ticketId.ticketNumber);
  }

  @Override
  public int hashCode() {
    return Objects.hash(reservation, ticketNumber);
  }
}
