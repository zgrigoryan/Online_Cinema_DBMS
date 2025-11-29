package com.cinema.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "ticket")
@IdClass(TicketId.class)
public class Ticket {

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "reservation_id", nullable = false)
  private Reservation reservation;

  @Id
  @Column(name = "ticket_number", nullable = false)
  private Integer ticketNumber;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "seat_id", nullable = false)
  private Seat seat;

  @Column(name = "ticket_price", nullable = false, precision = 10, scale = 2)
  private BigDecimal ticketPrice;

  @Column(name = "purchase_date", nullable = false)
  private LocalDateTime purchaseDate = LocalDateTime.now();
}
