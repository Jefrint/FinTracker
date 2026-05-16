package com.fintracker.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long jwtExpiration;

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // Generate JWT token for user
    public String generateToken(String email) {
        return Jwts.builder()
                .setSubject(email)  // User's email as the subject
                .setIssuedAt(new Date())  // When token was issued
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))  // Expires based on configured duration
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)  // Sign with HMAC-SHA256
                .compact();  // Build the token string
    }

    // Extract email from token (alias for extractUsername)
    public String extractUsername(String token) {
        return extractEmail(token);
    }

    // Extract email from token
    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // Extract expiration date
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // Extract any claim from token
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Extract all claims from token
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // Check if token is expired
    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // Validate token against user's email
    public Boolean validateToken(String token, String email) {
        final String tokenEmail = extractEmail(token);
        return (email.equals(tokenEmail) && !isTokenExpired(token));
    }

    // Validate token against UserDetails
    public Boolean validateToken(String token, org.springframework.security.core.userdetails.UserDetails userDetails) {
        final String tokenEmail = extractEmail(token);
        return (userDetails.getUsername().equals(tokenEmail) && !isTokenExpired(token));
    }
}
