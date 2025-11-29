package com.cinema.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "employee")
@PrimaryKeyJoinColumn(name = "employee_id")
public class Employee extends Person {

  @Column(nullable = false, length = 100)
  private String position;

  @Column(nullable = false, precision = 10, scale = 2)
  private BigDecimal salary;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "works_for_id")
  private Employee manager;
}
