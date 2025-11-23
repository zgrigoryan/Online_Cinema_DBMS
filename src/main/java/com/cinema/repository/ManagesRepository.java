package com.cinema.repository;

import com.cinema.domain.model.Manages;
import com.cinema.domain.model.Manages.ManagesId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ManagesRepository extends JpaRepository<Manages, ManagesId> {
}
