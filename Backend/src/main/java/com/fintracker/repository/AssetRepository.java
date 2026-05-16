package com.fintracker.repository;

import com.fintracker.entity.Asset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long> {
    List<Asset> findByUserEmail(String email);

    Optional<Asset> findByIdAndUserEmail(Long id, String email);
}
