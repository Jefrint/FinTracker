package com.fintracker.controller;

import com.fintracker.dto.request.AssetRequestDTO;
import com.fintracker.dto.response.AssetResponseDTO;
import com.fintracker.service.AssetService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/assets")
public class AssetController {

    private final AssetService assetService;

    public AssetController(AssetService assetService) {
        this.assetService = assetService;
    }

    @PostMapping
    public ResponseEntity<AssetResponseDTO> createAsset(@Valid @RequestBody AssetRequestDTO request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(assetService.createAsset(request, email));
    }

    @GetMapping
    public List<AssetResponseDTO> getAllAssets() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return assetService.getAllAssets(email);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AssetResponseDTO> getAsset(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(assetService.getAsset(id, email));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAsset(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        assetService.deleteAsset(id, email);
        return ResponseEntity.noContent().build();
    }

}
