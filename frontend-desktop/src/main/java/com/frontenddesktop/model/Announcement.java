package com.frontenddesktop.model;

import com.google.gson.annotations.SerializedName;

/**
 * Model representing an Announcement for the University Project.
 * Supports digital evangelization missions and department-wide campaigns. [cite: 2026-02-13]
 */
public class Announcement {
    @SerializedName("announcement_id")
    private int announcementId;

    @SerializedName("poster_id")
    private int posterId;

    private String title;
    private String content;

    @SerializedName("attachment_path")
    private String attachmentPath;

    @SerializedName("target_dept")
    private String targetDept;

    @SerializedName("created_at")
    private String createdAt;

    // --- NEW FIELDS FOR SENDER IDENTITY ---
    @SerializedName("sender_name")
    private String senderName;

    @SerializedName("sender_role")
    private String senderRole;

    public Announcement() {}

    // --- Getters ---

    public int getAnnouncementId() { return announcementId; }
    public int getPosterId() { return posterId; }
    public String getTitle() { return title; }
    public String getContent() { return content; }

    // Alias for Controller compatibility [cite: 2026-01-21]
    public String getAttachment_path() { return attachmentPath; }
    public String getAttachmentPath() { return attachmentPath; }

    public String getTargetDept() { return targetDept; }

    // Alias for Controller compatibility [cite: 2026-01-21]
    public String getCreated_at() { return createdAt; }
    public String getCreatedAt() { return createdAt; }

    // New Getters for Sender Identity
    public String getSenderName() { return senderName; }
    public String getSenderRole() { return senderRole; }

    // --- Setters (Required for GSON parsing) ---

    public void setAnnouncementId(int announcementId) { this.announcementId = announcementId; }
    public void setPosterId(int posterId) { this.posterId = posterId; }
    public void setTitle(String title) { this.title = title; }
    public void setContent(String content) { this.content = content; }
    public void setAttachmentPath(String attachmentPath) { this.attachmentPath = attachmentPath; }
    public void setTargetDept(String targetDept) { this.targetDept = targetDept; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    // New Setters for Sender Identity
    public void setSenderName(String senderName) { this.senderName = senderName; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }
}