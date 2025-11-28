package com.cinema.repository;

import com.cinema.domain.model.Promotion;
import java.time.LocalDate;
import java.util.Optional;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PromotionRepository extends JpaRepository<Promotion, Long> {
  Optional<Promotion> findByCode(String code);

  @Query("SELECT p FROM Promotion p WHERE p.code = :code AND p.active = true AND p.validFrom <= :today AND p.validTo >= :today")
  Optional<Promotion> findActiveByCode(@org.springframework.data.repository.query.Param("code") String code,
                                       @org.springframework.data.repository.query.Param("today") LocalDate today);

  List<Promotion> findByActiveTrue();
}
