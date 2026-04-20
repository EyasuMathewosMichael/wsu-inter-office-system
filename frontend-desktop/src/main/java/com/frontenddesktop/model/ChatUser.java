package com.frontenddesktop.model;

/**
 * Model representing a chat participant (Individual or Department Group).
 * Updated to support unread notifications and department-based filtering. [cite: 2026-02-27]
 */
public class ChatUser {
    private final int id;
    private final String name;
    private String lastMessage;
    private boolean isOnline;
    private final String department;
    private int unreadCount;

    public ChatUser(int id, String name, String lastMessage, boolean isOnline, String department, int unreadCount) {
        this.id = id;
        this.name = name;
        this.lastMessage = lastMessage;
        this.isOnline = isOnline;
        // Default to "N/A" if department is null to prevent UI rendering issues [cite: 2026-01-28]
        this.department = (department != null) ? department : "N/A";
        this.unreadCount = unreadCount;
    }

    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public String getLastMessage() { return lastMessage; }
    public boolean isOnline() { return isOnline; }
    public String getDepartment() { return department; }
    public int getUnreadCount() { return unreadCount; }

    // Setters
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }
    public void setOnline(boolean online) { isOnline = online; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }

    /**
     * Overridden to assist with debugging and potential simple list rendering.
     */
    @Override
    public String toString() {
        return "ChatUser{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", dept='" + department + '\'' +
                ", unread=" + unreadCount +
                '}';
    }
}