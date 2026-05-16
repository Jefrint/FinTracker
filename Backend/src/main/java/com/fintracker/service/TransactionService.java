package com.fintracker.service;

import com.fintracker.dto.request.TransactionRequestDTO;
import com.fintracker.dto.response.TransactionResponseDTO;
import com.fintracker.entity.Asset;
import com.fintracker.entity.Transaction;
import com.fintracker.exception.ResourceNotFoundException;
import com.fintracker.repository.AssetRepository;
import com.fintracker.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final AssetRepository assetRepository;

    public TransactionService(TransactionRepository transactionRepository, AssetRepository assetRepository) {
        this.transactionRepository = transactionRepository;
        this.assetRepository = assetRepository;
    }

    public TransactionResponseDTO createTransaction(TransactionRequestDTO request, String email) {
        Asset asset = assetRepository.findByIdAndUserEmail(request.getAssetId(), email)
                .orElseThrow(() -> new ResourceNotFoundException("Asset not found"));

        Transaction tx = new Transaction();
        tx.setQuantity(request.getQuantity());
        tx.setPrice(request.getPrice());
        tx.setType(request.getType());
        tx.setDate(request.getDate());
        tx.setAsset(asset);

        Transaction saved = transactionRepository.save(tx);
        return toResponse(saved);
    }

    public List<TransactionResponseDTO> getAllTransactions(String email) {
        return transactionRepository.findByAssetUserEmail(email).stream().map(this::toResponse).collect(Collectors.toList());
    }

    public TransactionResponseDTO getTransaction(Long id, String email) {
        return transactionRepository.findByIdAndAssetUserEmail(id, email)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found"));
    }

    public void deleteTransaction(Long id, String email) {
        Transaction transaction = transactionRepository.findByIdAndAssetUserEmail(id, email)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found"));
        transactionRepository.delete(transaction);
    }

    private TransactionResponseDTO toResponse(Transaction tx) {
        return new TransactionResponseDTO(tx.getId(), tx.getQuantity(), tx.getPrice(), tx.getType(), tx.getDate(), tx.getAsset().getId());
    }
}
