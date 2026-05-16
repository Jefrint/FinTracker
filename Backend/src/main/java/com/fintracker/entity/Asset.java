package com.fintracker.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "assets")
public class Asset {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;   // BTC, TCS
    private String type;   // STOCK, CRYPTO, GOLD

    // Many assets → one user
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    // One asset → many transactions
    @OneToMany(mappedBy = "asset", cascade = CascadeType.ALL)
    private List<Transaction> transactions;

    // getters & setters
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<Transaction> getTransactions() {
        return transactions;
    }

    public void setTransactions(List<Transaction> transactions) {
        this.transactions = transactions;
    }
}