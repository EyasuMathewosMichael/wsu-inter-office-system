package com.frontenddesktop.model;

import com.google.gson.annotations.SerializedName;

public class Task {
    @SerializedName("task_id")
    private int taskId;

    @SerializedName("creator_id")
    private int creatorId;

    @SerializedName("assignee_id")
    private int assigneeId;

    private String title;
    private String description;
    private String priority;
    private String status;

    @SerializedName("due_date")
    private String dueDate;

    @SerializedName("initial_attachment_path")
    private String attachmentPath;

    // --- NEW FIELDS FOR STAFF REPLIES AND REVIEW ---

    @SerializedName("staff_reply_text")
    private String staffReplyText;

    @SerializedName("completion_attachment_path")
    private String completionPath;

    @SerializedName("acknowledged")
    private int acknowledged; // 0 for pending, 1 for acknowledged

    public Task() {}

    // --- STANDARD GETTERS ---
    public int getTaskId() { return taskId; }
    public int getCreatorId() { return creatorId; }
    public int getAssigneeId() { return assigneeId; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public String getPriority() { return priority; }
    public String getStatus() { return status; }
    public String getDueDate() { return dueDate; }
    public String getAttachmentPath() { return attachmentPath; }
    public String getStaffReplyText() { return staffReplyText; }
    public String getCompletionPath() { return completionPath; }
    public int getAcknowledged() { return acknowledged; }

    // --- ALIAS GETTERS (Resolves IDE Errors in image_22a5d9.png & image_22ae5a.png) ---

    /** * Required by TaskItemController.java
     * Resolves: cannot find symbol method getInitialAttachmentPath()
     */
    public String getInitialAttachmentPath() {
        return attachmentPath;
    }

    /** * Required by TaskItemController.java
     * Resolves: cannot find symbol method getCompletionAttachmentPath()
     */
    public String getCompletionAttachmentPath() {
        return completionPath;
    }

    /** * Required by TaskModalController.java
     * Resolves: Cannot resolve method 'getCompletionPath'
     */
    // Note: This matches your completionPath field directly,
    // but ensured it is public for the controller.
    // getCompletionPath() is already defined above.

    // --- SETTERS ---
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public void setTitle(String title) { this.title = title; }
    public void setStatus(String status) { this.status = status; }
    public void setStaffReplyText(String staffReplyText) { this.staffReplyText = staffReplyText; }
    public void setCompletionPath(String completionPath) { this.completionPath = completionPath; }

    /** Resolves setter issues in Reply Modals */
    public void setCompletionAttachmentPath(String path) { this.completionPath = path; }

    public void setAcknowledged(int acknowledged) { this.acknowledged = acknowledged; }
}