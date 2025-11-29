package com.cinema.repository;

import com.cinema.domain.model.Promotion;
import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PromotionRepository extends JpaRepository<Promotion, Long> {
  Optional<Promotion> findByCode(String code);

  @Query("SELECT p FROM Promotion p WHERE p.code = :code AND p.startDate <= :now AND p.endDate >= :now")
  Optional<Promotion> findActiveByCode(@org.springframework.data.repository.query.Param("code") String code,
                                       @org.springframework.data.repository.query.Param("now") LocalDateTime now);
}
