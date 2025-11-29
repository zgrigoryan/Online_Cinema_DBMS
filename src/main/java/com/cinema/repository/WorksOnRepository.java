package com.cinema.repository;

import com.cinema.domain.model.WorksOn;
import com.cinema.domain.model.WorksOn.WorksOnId;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorksOnRepository extends JpaRepository<WorksOn, WorksOnId> {
  List<WorksOn> findByMovie_Id(Long movieId);
}
