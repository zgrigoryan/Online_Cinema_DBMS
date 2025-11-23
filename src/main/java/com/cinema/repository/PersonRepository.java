package com.cinema.repository;

import com.cinema.domain.model.Person;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PersonRepository extends JpaRepository<Person, Long> {
  Optional<Person> findByEmail(String email);
}
