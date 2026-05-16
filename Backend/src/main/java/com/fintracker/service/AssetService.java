package com.fintracker.service;

import com.fintracker.dto.request.AssetRequestDTO;
import com.fintracker.dto.response.AssetResponseDTO;
import com.fintracker.entity.Asset;
import com.fintracker.entity.User;
import com.fintracker.exception.ResourceNotFoundException;
import com.fintracker.repository.AssetRepository;
import com.fintracker.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AssetService {

    private final AssetRepository assetRepository;
    private final UserRepository userRepository;

    public AssetService(AssetRepository assetRepository, UserRepository userRepository) {
        this.assetRepository = assetRepository;
        this.userRepository = userRepository;
    }

    public AssetResponseDTO createAsset(AssetRequestDTO request, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Authenticated user not found"));

        Asset asset = new Asset();
        asset.setName(request.getName());
        asset.setType(request.getType());
        asset.setUser(user);

        Asset saved = assetRepository.save(asset);
        return toResponse(saved);
    }

    public List<AssetResponseDTO> getAllAssets(String email) {
        return assetRepository.findByUserEmail(email).stream().map(this::toResponse).collect(Collectors.toList());
    }

    public AssetResponseDTO getAsset(Long id, String email) {
        return assetRepository.findByIdAndUserEmail(id, email)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Asset not found"));
    }

    public void deleteAsset(Long id, String email) {
        Asset asset = assetRepository.findByIdAndUserEmail(id, email)
                .orElseThrow(() -> new ResourceNotFoundException("Asset not found"));
        assetRepository.delete(asset);
    }

    private AssetResponseDTO toResponse(Asset asset) {
        List<Long> transactionIds = asset.getTransactions() == null ? List.of() :
                asset.getTransactions().stream().map(t -> t.getId()).collect(Collectors.toList());
        return new AssetResponseDTO(asset.getId(), asset.getName(), asset.getType(), asset.getUser().getId(), transactionIds);
    }
}
