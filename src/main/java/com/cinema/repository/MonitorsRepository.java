package com.cinema.repository;

import com.cinema.domain.model.Monitors;
import com.cinema.domain.model.Monitors.MonitorsId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MonitorsRepository extends JpaRepository<Monitors, MonitorsId> {
}
