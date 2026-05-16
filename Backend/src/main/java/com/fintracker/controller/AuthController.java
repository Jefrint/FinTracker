package com.fintracker.controller;

import com.fintracker.dto.request.LoginRequestDTO;
import com.fintracker.dto.request.UserRequestDTO;
import com.fintracker.dto.response.AuthResponseDTO;
import com.fintracker.dto.response.UserResponseDTO;
import com.fintracker.entity.User;
import com.fintracker.service.UserService;
import com.fintracker.util.JwtUtil;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    public AuthController(UserService userService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponseDTO> register(@Valid @RequestBody UserRequestDTO request) {
        UserResponseDTO created = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO loginRequest) {
        // Find user by email
        Optional<User> userOpt = userService.findByEmail(loginRequest.getEmail());
        
        // Check if user exists and password matches
        if (userOpt.isPresent() && userService.checkPassword(userOpt.get(), loginRequest.getPassword())) {
            User user = userOpt.get();
            
            // Generate JWT token
            String token = jwtUtil.generateToken(user.getEmail());
            
            // Create response with token and user info
            AuthResponseDTO response = new AuthResponseDTO(
                token,
                user.getId(),
                user.getName(),
                user.getEmail()
            );
            
            return ResponseEntity.ok(response);
        }
        
        // Invalid credentials
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        // For JWT, logout is handled client-side (delete token)
        // Server-side would require token blacklisting
        return ResponseEntity.ok("Logged out successfully");
    }
}