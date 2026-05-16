package com.fintracker.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public class TransactionRequestDTO {
    @NotNull(message = "Quantity is required")
    @Positive(message = "Quantity must be greater than 0")
    private Double quantity;

    @NotNull(message = "Price is required")
    @Positive(message = "Price must be greater than 0")
    private Double price;

    @NotBlank(message = "Transaction type is required")
    private String type;

    @NotNull(message = "Transaction date is required")
    private LocalDate date;

    @NotNull(message = "Asset id is required")
    private Long assetId;

    // Default constructor
    public TransactionRequestDTO() {}

    // Constructor with fields
    public TransactionRequestDTO(Double quantity, Double price, String type, LocalDate date, Long assetId) {
        this.quantity = quantity;
        this.price = price;
        this.type = type;
        this.date = date;
        this.assetId = assetId;
    }

    // Getters and setters
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
