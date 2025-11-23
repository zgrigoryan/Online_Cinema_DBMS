package com.cinema.web.controller;

import com.cinema.service.AuthService;
import com.cinema.web.dto.auth.AuthResponse;
import com.cinema.web.dto.auth.LoginRequest;
import com.cinema.web.dto.auth.RegisterRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/register")
  public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
    String token = authService.registerCustomer(request.getFirstName(), request.getLastName(),
        request.getEmail(), request.getPassword(), request.getPhone());
    return ResponseEntity.ok(new AuthResponse(token));
  }

  @PostMapping("/login")
  public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
    String token = authService.login(request.getEmail(), request.getPassword());
    return ResponseEntity.ok(new AuthResponse(token));
  }
}
