package com.cinema.repository;

import com.cinema.domain.model.WorksOn;
import com.cinema.domain.model.WorksOn.WorksOnId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorksOnRepository extends JpaRepository<WorksOn, WorksOnId> {
}
