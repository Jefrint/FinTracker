package com.fintracker.service;

import com.fintracker.dto.request.UserRequestDTO;
import com.fintracker.dto.response.UserResponseDTO;
import com.fintracker.entity.User;
import com.fintracker.exception.DuplicateResourceException;
import com.fintracker.exception.ResourceNotFoundException;
import com.fintracker.repository.UserRepository;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
         this.passwordEncoder = passwordEncoder;
    }

public Optional<User> findByEmail(String email) {
    return userRepository.findByEmail(email);
}

public UserResponseDTO getUserByEmail(String email) {
    return userRepository.findByEmail(email)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
}

public boolean checkPassword(User user, String rawPassword) {
    return passwordEncoder.matches(rawPassword, user.getPassword());
}

    public UserResponseDTO createUser(UserRequestDTO request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email is already registered");
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        User saved = userRepository.save(user);
        return toResponse(saved);
    }

    public List<UserResponseDTO> getAllUsers(String email) {
        return userRepository.findByEmail(email).stream().map(this::toResponse).collect(Collectors.toList());
    }

    public UserResponseDTO getUser(Long id, String email) {
        return userRepository.findByIdAndEmail(id, email)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public UserResponseDTO updateUser(Long id, String email, UserRequestDTO request) {
        User user = userRepository.findByIdAndEmail(id, email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (userRepository.existsByEmailAndIdNot(request.getEmail(), id)) {
            throw new DuplicateResourceException("Email is already registered");
        }

        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        User updated = userRepository.save(user);
        return toResponse(updated);
    }

    public void deleteUser(Long id, String email) {
        User user = userRepository.findByIdAndEmail(id, email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        userRepository.delete(user);
    }

    private UserResponseDTO toResponse(User user) {
        return new UserResponseDTO(user.getId(), user.getName(), user.getEmail());
    }
}
