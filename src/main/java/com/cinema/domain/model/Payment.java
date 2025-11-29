package com.cinema.domain.model;

import com.cinema.domain.enums.PaymentMethod;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "payment")
public class Payment {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "payment_id")
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "promotion_id")
  private Promotion promotion;

  @Column(name = "final_amount", nullable = false, precision = 10, scale = 2)
  private BigDecimal finalAmount = BigDecimal.ZERO;

  @Enumerated(EnumType.STRING)
  @Column(name = "payment_method", nullable = false, length = 30)
  private PaymentMethod paymentMethod = PaymentMethod.CREDIT_CARD;

  @Column(name = "payment_date", nullable = false)
  private LocalDateTime paymentDate = LocalDateTime.now();

  @OneToMany(mappedBy = "payment", fetch = FetchType.LAZY)
  private List<Reservation> reservations = new ArrayList<>();
}
