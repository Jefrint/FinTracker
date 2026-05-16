package com.fintracker.dto.response;

import java.time.LocalDateTime;
import java.util.Map;

public class ErrorResponseDTO {
    private final String message;
    private final LocalDateTime timestamp;
    private final Map<String, String> errors;

    public ErrorResponseDTO(String message, LocalDateTime timestamp, Map<String, String> errors) {
        this.message = message;
        this.timestamp = timestamp;
        this.errors = errors;
    }

    public String getMessage() {
        return message;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public Map<String, String> getErrors() {
        return errors;
    }
}
