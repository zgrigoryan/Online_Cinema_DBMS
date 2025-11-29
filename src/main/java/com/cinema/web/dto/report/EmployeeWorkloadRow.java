package com.cinema.web.dto.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class EmployeeWorkloadRow {
  private Long employeeId;
  private String name;
  private java.time.LocalDate showDate;
  private Long sessionsMonitored;
}
