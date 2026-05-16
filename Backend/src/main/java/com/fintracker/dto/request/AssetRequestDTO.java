package com.fintracker.dto.request;

import jakarta.validation.constraints.NotBlank;

public class AssetRequestDTO {
    @NotBlank(message = "Asset name is required")
    private String name;

    @NotBlank(message = "Asset type is required")
    private String type;

    // Default constructor
    public AssetRequestDTO() {}

    // Constructor with fields
    public AssetRequestDTO(String name, String type) {
        this.name = name;
        this.type = type;
    }

    // Getters and setters
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
}
