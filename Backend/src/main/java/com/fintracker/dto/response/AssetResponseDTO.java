package com.fintracker.dto.response;

import java.util.List;

public class AssetResponseDTO {
    private Long id;
    private String name;
    private String type;
    private Long userId;
    private List<Long> transactionIds; // List of transaction IDs

    // Default constructor
    public AssetResponseDTO() {}

    // Constructor with fields
    public AssetResponseDTO(Long id, String name, String type, Long userId, List<Long> transactionIds) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.userId = userId;
        this.transactionIds = transactionIds;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public List<Long> getTransactionIds() {
        return transactionIds;
    }

    public void setTransactionIds(List<Long> transactionIds) {
        this.transactionIds = transactionIds;
    }
}