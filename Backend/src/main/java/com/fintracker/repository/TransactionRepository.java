package com.fintracker.repository;

import com.fintracker.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByAssetUserEmail(String email);

    Optional<Transaction> findByIdAndAssetUserEmail(Long id, String email);
}
