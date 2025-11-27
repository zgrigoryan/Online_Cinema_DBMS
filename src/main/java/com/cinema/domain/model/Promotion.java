package com.cinema.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "promotion")
public class Promotion {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, unique = true, length = 50)
  private String code;

  @Column(columnDefinition = "TEXT")
  private String description;

  @Column(nullable = false, precision = 5, scale = 2)
  private BigDecimal discountPercent;

  @Column(nullable = false)
  private LocalDate validFrom;

  @Column(nullable = false)
  private LocalDate validTo;

  @Column(nullable = false)
  private Boolean active = Boolean.TRUE;

  @Column(nullable = false, precision = 10, scale = 2)
  private BigDecimal minAmount = BigDecimal.ZERO;

  private Integer usageLimit;

  @Column(nullable = false)
  private Integer timesRedeemed = 0;
}
