package com.frontenddesktop.model;

import com.google.gson.annotations.SerializedName;

public class User {
    // Matches 'user_id' from your JSP/MySQL schema [cite: 2026-01-26]
    @SerializedName("id")
    private int id;

    private String username;
    private String role; // Essential for role-based dashboard logic [cite: 2026-01-28]

    // No-args constructor required for Gson deserialization [cite: 2026-01-21]
    public User() {}

    // Constructor for manual instantiation
    public User(int id, String username) {
        this.id = id;
        this.username = username;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    /**
     * The ComboBox uses toString() to decide what text to show to the user.
     * This ensures the Dept Head sees names instead of memory addresses [cite: 2026-01-21].
     */
    @Override
    public String toString() {
        return username;
    }
}