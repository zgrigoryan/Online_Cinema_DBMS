package com.cinema.web.controller;

import com.cinema.domain.model.Person;
import com.cinema.repository.PersonRepository;
import com.cinema.web.dto.customer.UpdateProfileRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/customers")
@PreAuthorize("hasRole('CUSTOMER')")
public class CustomerController {

  private final PersonRepository personRepository;

  public CustomerController(PersonRepository personRepository) {
    this.personRepository = personRepository;
  }

  @PutMapping("/me")
  public ResponseEntity<Person> updateProfile(@AuthenticationPrincipal Person person,
                                              @Valid @RequestBody UpdateProfileRequest request) {
    person.setFirstName(request.getFirstName());
    person.setLastName(request.getLastName());
    person.setPhone(request.getPhone());
    if (request.getEmail() != null && !request.getEmail().equalsIgnoreCase(person.getEmail())) {
      person.setEmail(request.getEmail());
    }
    Person saved = personRepository.save(person);
    return ResponseEntity.ok(saved);
  }
}
