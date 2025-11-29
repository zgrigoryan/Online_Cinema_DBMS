package com.cinema.domain.model;

import com.cinema.domain.enums.HallType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "cinema_hall")
public class CinemaHall {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "hall_id")
  private Long id;

  @Column(nullable = false, unique = true, length = 100)
  private String name;

  @Column(nullable = false)
  private Integer capacity;

  @Enumerated(EnumType.STRING)
  @Column(name = "type", nullable = false, length = 20)
  private HallType type;
}
