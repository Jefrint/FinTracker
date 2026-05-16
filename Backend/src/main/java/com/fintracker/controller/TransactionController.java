package com.fintracker.controller;

import com.fintracker.dto.request.TransactionRequestDTO;
import com.fintracker.dto.response.TransactionResponseDTO;
import com.fintracker.service.TransactionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/transactions")
public class TransactionController {

    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @PostMapping
    public ResponseEntity<TransactionResponseDTO> createTransaction(@Valid @RequestBody TransactionRequestDTO request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(transactionService.createTransaction(request, email));
    }

    @GetMapping
    public List<TransactionResponseDTO> getAllTransactions() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return transactionService.getAllTransactions(email);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponseDTO> getTransaction(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(transactionService.getTransaction(id, email));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        transactionService.deleteTransaction(id, email);
        return ResponseEntity.noContent().build();
    }

}
