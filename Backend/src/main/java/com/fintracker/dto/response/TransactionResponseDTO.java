package com.fintracker.dto.response;

import java.time.LocalDate;

public class TransactionResponseDTO {
    private Long id;
    private Double quantity;
    private Double price;
    private String type;
    private LocalDate date;
    private Long assetId;

    // Default constructor
    public TransactionResponseDTO() {}

    // Constructor with fields
    public TransactionResponseDTO(Long id, Double quantity, Double price, String type, LocalDate date, Long assetId) {
        this.id = id;
        this.quantity = quantity;
        this.price = price;
        this.type = type;
        this.date = date;
        this.assetId = assetId;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Double getQuantity() {
        return quantity;
    }

    public void setQuantity(Double quantity) {
        this.quantity = quantity;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public Long getAssetId() {
        return assetId;
    }

    public void setAssetId(Long assetId) {
        this.assetId = assetId;
    }
}