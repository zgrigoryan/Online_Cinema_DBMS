package com.cinema.web.controller;

import com.cinema.domain.model.CinemaHall;
import com.cinema.domain.model.Employee;
import com.cinema.domain.model.Person;
import com.cinema.domain.model.Session;
import com.cinema.repository.CinemaHallRepository;
import com.cinema.repository.EmployeeRepository;
import com.cinema.repository.ManagesRepository;
import com.cinema.repository.MonitorsRepository;
import com.cinema.repository.PersonRepository;
import com.cinema.repository.SessionRepository;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/employees")
@PreAuthorize("hasRole('ADMIN')")
public class AdminEmployeeController {

  private final EmployeeRepository employeeRepository;
  private final PersonRepository personRepository;
  private final PasswordEncoder passwordEncoder;
  private final SessionRepository sessionRepository;
  private final MonitorsRepository monitorsRepository;
  private final CinemaHallRepository hallRepository;
  private final ManagesRepository managesRepository;

  public AdminEmployeeController(EmployeeRepository employeeRepository,
                                 PersonRepository personRepository,
                                 PasswordEncoder passwordEncoder,
                                 SessionRepository sessionRepository,
                                 MonitorsRepository monitorsRepository,
                                 CinemaHallRepository hallRepository,
                                 ManagesRepository managesRepository) {
    this.employeeRepository = employeeRepository;
    this.personRepository = personRepository;
    this.passwordEncoder = passwordEncoder;
    this.sessionRepository = sessionRepository;
    this.monitorsRepository = monitorsRepository;
    this.hallRepository = hallRepository;
    this.managesRepository = managesRepository;
  }

  @GetMapping
  public List<Employee> list() {
    return employeeRepository.findAll();
  }

  @PostMapping
  public ResponseEntity<Employee> create(@RequestParam @NotBlank String firstName,
                                         @RequestParam @NotBlank String lastName,
                                         @RequestParam @NotBlank String email,
                                         @RequestParam @NotBlank String password,
                                         @RequestParam @NotBlank String jobTitle) {
    if (personRepository.findByEmail(email).isPresent()) {
      return ResponseEntity.badRequest().build();
    }
    Person p = new Person();
    p.setFirstName(firstName);
    p.setLastName(lastName);
    p.setEmail(email);
    p.setPasswordHash(passwordEncoder.encode(password));
    p.setRole(com.cinema.domain.enums.Role.STAFF);
    personRepository.save(p);

    Employee e = new Employee();
    e.setId(p.getId());
    e.setJobTitle(jobTitle);
    e.setActive(true);
    Employee saved = employeeRepository.save(e);
    return ResponseEntity.ok(saved);
  }

  @PostMapping("/{employeeId}/monitor/{sessionId}")
  public ResponseEntity<?> assignMonitor(@PathVariable Long employeeId, @PathVariable Long sessionId) {
    Employee emp = employeeRepository.findById(employeeId).orElseThrow();
    Session session = sessionRepository.findById(sessionId).orElseThrow();
    com.cinema.domain.model.Monitors rel = new com.cinema.domain.model.Monitors();
    rel.setEmployee(emp);
    rel.setSession(session);
    monitorsRepository.save(rel);
    return ResponseEntity.ok().build();
  }

  @PostMapping("/{employeeId}/manage/{hallId}")
  public ResponseEntity<?> assignManage(@PathVariable Long employeeId, @PathVariable Long hallId) {
    Employee emp = employeeRepository.findById(employeeId).orElseThrow();
    CinemaHall hall = hallRepository.findById(hallId).orElseThrow();
    com.cinema.domain.model.Manages rel = new com.cinema.domain.model.Manages();
    rel.setEmployee(emp);
    rel.setHall(hall);
    managesRepository.save(rel);
    return ResponseEntity.ok().build();
  }
}
