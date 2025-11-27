package com.cinema.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.security.core.userdetails.UserDetails;

@Component
public class JwtService {

  private final Key signingKey;
  private final long validityMinutes;

  // Default secret is 256-bit base64 to satisfy HS256 requirements
  public JwtService(@Value("${security.jwt.secret:QkFTRTY0REVGQVVMVEtFWTIzNDU2Nzg5MDEyMzQ1Njc4OTA=}") String secret,
                    @Value("${security.jwt.minutes:60}") long validityMinutes) {
    this.signingKey = Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret));
    this.validityMinutes = validityMinutes;
  }

  public String generateToken(UserDetails userDetails) {
    Instant now = Instant.now();
    return Jwts.builder()
        .subject(userDetails.getUsername())
        .issuedAt(Date.from(now))
        .expiration(Date.from(now.plus(validityMinutes, ChronoUnit.MINUTES)))
        .signWith(signingKey)
        .compact();
  }

  public String extractUsername(String token) {
    return Jwts.parser()
        .verifyWith((javax.crypto.SecretKey) signingKey)
        .build()
        .parseSignedClaims(token)
        .getPayload()
        .getSubject();
  }
}
