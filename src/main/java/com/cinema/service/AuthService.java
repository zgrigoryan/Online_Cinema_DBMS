package com.cinema.service;

import com.cinema.domain.model.Customer;
import com.cinema.domain.model.Person;
import com.cinema.repository.CustomerRepository;
import com.cinema.repository.PersonRepository;
import com.cinema.security.JwtService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

  private final PersonRepository personRepository;
  private final CustomerRepository customerRepository;
  private final PasswordEncoder passwordEncoder;
  private final AuthenticationManager authenticationManager;
  private final JwtService jwtService;

  public AuthService(PersonRepository personRepository,
                     CustomerRepository customerRepository,
                     PasswordEncoder passwordEncoder,
                     AuthenticationManager authenticationManager,
                     JwtService jwtService) {
    this.personRepository = personRepository;
    this.customerRepository = customerRepository;
    this.passwordEncoder = passwordEncoder;
    this.authenticationManager = authenticationManager;
    this.jwtService = jwtService;
  }

  @Transactional
  public String registerCustomer(String firstName, String lastName, String email, String password, String phone) {
    if (personRepository.findByEmail(email).isPresent()) {
      throw new IllegalArgumentException("Email already in use");
    }
    Customer customer = new Customer();
    customer.setFirstName(firstName);
    customer.setLastName(lastName);
    customer.setEmail(email);
    customer.setPhone(phone);
    customer.setPasswordHash(passwordEncoder.encode(password));
    customerRepository.save(customer);
    return jwtService.generateToken(customer);
  }

  public String login(String email, String password) {
    authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(email, password));
    Person person = personRepository.findByEmail(email)
        .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));
    return jwtService.generateToken(person);
  }
}
