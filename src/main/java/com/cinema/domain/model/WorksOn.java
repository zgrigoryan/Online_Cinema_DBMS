package com.cinema.domain.model;

import jakarta.persistence.Column;
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
@Table(name = "works_on")
@IdClass(WorksOn.WorksOnId.class)
public class WorksOn {

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "employee_id", nullable = false)
  private Employee employee;

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "movie_id", nullable = false)
  private Movie movie;

  @Id
  @Column(nullable = false, length = 100)
  private String role;

  @Getter
  @Setter
  @NoArgsConstructor
  public static class WorksOnId implements Serializable {
    private Long employee;
    private Long movie;
    private String role;

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;
      WorksOnId that = (WorksOnId) o;
      return Objects.equals(employee, that.employee)
          && Objects.equals(movie, that.movie)
          && Objects.equals(role, that.role);
    }

    @Override
    public int hashCode() {
      return Objects.hash(employee, movie, role);
    }
  }
}
