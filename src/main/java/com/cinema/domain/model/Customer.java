package com.cinema.domain.model;

import com.cinema.domain.enums.MembershipStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "customer")
@PrimaryKeyJoinColumn(name = "customer_id")
public class Customer extends Person {

  @Enumerated(EnumType.STRING)
  @Column(name = "membership_status", nullable = false, length = 20)
  private MembershipStatus membershipStatus = MembershipStatus.REGULAR;

  @Column(name = "registration_date", nullable = false)
  private LocalDateTime registrationDate = LocalDateTime.now();
}
