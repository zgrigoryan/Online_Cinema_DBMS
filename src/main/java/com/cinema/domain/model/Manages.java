package com.cinema.domain.model;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.Objects;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "manages")
@IdClass(Manages.ManagesId.class)
public class Manages {

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "employee_id", nullable = false)
  private Employee employee;

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "hall_id", nullable = false)
  private CinemaHall hall;

  @Getter
  @Setter
  @NoArgsConstructor
  public static class ManagesId implements Serializable {
    private Long employee;
    private Long hall;

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;
      ManagesId that = (ManagesId) o;
      return Objects.equals(employee, that.employee) && Objects.equals(hall, that.hall);
    }

    @Override
    public int hashCode() {
      return Objects.hash(employee, hall);
    }
  }
}
