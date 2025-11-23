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
@Table(name = "monitors")
@IdClass(Monitors.MonitorsId.class)
public class Monitors {

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "employee_id", nullable = false)
  private Employee employee;

  @Id
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "session_id", nullable = false)
  private Session session;

  @Getter
  @Setter
  @NoArgsConstructor
  public static class MonitorsId implements Serializable {
    private Long employee;
    private Long session;

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;
      MonitorsId that = (MonitorsId) o;
      return Objects.equals(employee, that.employee) && Objects.equals(session, that.session);
    }

    @Override
    public int hashCode() {
      return Objects.hash(employee, session);
    }
  }
}
