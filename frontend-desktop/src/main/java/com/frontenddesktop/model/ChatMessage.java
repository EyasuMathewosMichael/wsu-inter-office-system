package com.frontenddesktop.model;

import com.google.gson.annotations.SerializedName;

public class ChatMessage {
    @SerializedName("chat_id")
    private int chatId;

    @SerializedName("sender_id")
    private int sender_id;

    @SerializedName("receiver_id")
    private int receiverId;

    @SerializedName("message")
    private String message;

    @SerializedName("attachment_path")
    private String attachmentPath;

    @SerializedName("is_read")
    private int isRead;

    @SerializedName("sent_at")
    private String sentAt;

    // Getters
    public int getSenderId() { return sender_id; }
    public String getMessageText() { return message; }
    public String getSentAt() { return sentAt; }
    public String getAttachmentPath() { return attachmentPath; }
}