package com.fintracker.controller;

import com.fintracker.dto.request.UserRequestDTO;
import com.fintracker.dto.response.UserResponseDTO;
import com.fintracker.service.UserService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<UserResponseDTO> getAllUsers() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userService.getAllUsers(email);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDTO> getUser(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(userService.getUser(id, email));
    }
    @GetMapping("/me")
    public ResponseEntity<UserResponseDTO> getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(userService.getUserByEmail(email));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponseDTO> updateUser(@PathVariable Long id, @Valid @RequestBody UserRequestDTO request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(userService.updateUser(id, email, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        userService.deleteUser(id, email);
        return ResponseEntity.noContent().build();
    }
}
