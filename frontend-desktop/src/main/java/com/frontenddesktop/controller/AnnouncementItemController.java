package com.frontenddesktop.controller;

import com.frontenddesktop.model.Announcement;
import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import java.awt.Desktop;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class AnnouncementItemController {

    @FXML private VBox rootNode;
    @FXML private Label lblSender, lblTitle, lblContent, lblDate;
    @FXML private Button btnDownload, btnViewMore;
    @FXML private HBox adminControls;

    private Announcement currentAnnouncement;
    private Runnable refreshCallback;

    public void setData(Announcement announcement, String currentUserRole, Runnable refreshCallback) {
        this.currentAnnouncement = announcement;
        this.refreshCallback = refreshCallback;

        // 1. Precise Permission Logic [cite: 2026-01-28]
        String role = (currentUserRole != null) ? currentUserRole.trim() : "";
        boolean isAdmin = role.equalsIgnoreCase("Admin");

        // Ownership check: session user ID vs the poster_id from the database
        boolean isOwner = (announcement.getPosterId() == UserSession.getUserId());

        // Dept Head can only modify their own posts. Admin can modify all.
        boolean canModify = isAdmin || (role.equalsIgnoreCase("Dept Head") && isOwner);
        adminControls.setVisible(canModify);

        // --- UI Rendering ---
        if (announcement.getSenderName() != null) {
            lblSender.setText(announcement.getSenderName() + " (" + announcement.getSenderRole() + ")");
            lblSender.setStyle(announcement.getSenderRole().equalsIgnoreCase("Admin") ?
                    "-fx-text-fill: #7c3aed; -fx-font-weight: bold;" :
                    "-fx-text-fill: #3b82f6; -fx-font-weight: bold;");
        }

        lblTitle.setText(announcement.getTitle() != null ? announcement.getTitle() : "Untitled");
        lblContent.setText(announcement.getContent());
        btnViewMore.setVisible(announcement.getContent() != null && announcement.getContent().length() > 120);
        lblDate.setText(announcement.getCreated_at() != null ? announcement.getCreated_at() : "Recently");

        // attachmentPath check for reels and visuals [cite: 2026-02-13]
        btnDownload.setVisible(announcement.getAttachment_path() != null && !announcement.getAttachment_path().trim().isEmpty());
    }

    @FXML
    private void handleEdit() {
        // Modal for storytelling refinement [cite: 2026-02-13, 2026-01-21]
        Dialog<ButtonType> dialog = new Dialog<>();
        dialog.setTitle("Edit Broadcast");
        dialog.setHeaderText("Update content for: " + currentAnnouncement.getTitle());

        ButtonType saveBtn = new ButtonType("Save Changes", ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().addAll(saveBtn, ButtonType.CANCEL);

        TextField titleField = new TextField(currentAnnouncement.getTitle());
        TextArea contentArea = new TextArea(currentAnnouncement.getContent());
        contentArea.setWrapText(true);

        VBox layout = new VBox(10, new Label("Title:"), titleField, new Label("Content:"), contentArea);
        layout.setPrefWidth(450);
        dialog.getDialogPane().setContent(layout);

        Optional<ButtonType> result = dialog.showAndWait();
        if (result.isPresent() && result.get() == saveBtn) {
            performUpdate(titleField.getText(), contentArea.getText());
        }
    }

    private void performUpdate(String title, String content) {
        new Thread(() -> {
            try {
                // Using Map to satisfy HttpConnector.post(String, Map) signature
                Map<String, String> params = new HashMap<>();
                params.put("id", String.valueOf(currentAnnouncement.getAnnouncementId()));
                params.put("title", title);
                params.put("content", content);

                String response = HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("update_announcement.jsp"), params);
                if (response != null && response.contains("success")) {
                    Platform.runLater(refreshCallback);
                }
            } catch (Exception e) { e.printStackTrace(); }
        }).start();
    }

    @FXML
    private void handleDelete() {
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION, "Delete this mission post?", ButtonType.YES, ButtonType.NO);
        confirm.showAndWait().ifPresent(res -> {
            if (res == ButtonType.YES) {
                new Thread(() -> {
                    try {
                        Map<String, String> params = new HashMap<>();
                        params.put("id", String.valueOf(currentAnnouncement.getAnnouncementId()));
                        String response = HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("delete_announcement.jsp"), params);
                        if (response != null && response.contains("success")) {
                            Platform.runLater(refreshCallback);
                        }
                    } catch (Exception e) { e.printStackTrace(); }
                }).start();
            }
        });
    }

    @FXML
    private void handleViewFullAnnouncement() {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Broadcast Details");
        alert.setHeaderText(currentAnnouncement.getTitle());
        TextArea area = new TextArea(currentAnnouncement.getContent());
        area.setEditable(false);
        area.setWrapText(true);
        alert.getDialogPane().setContent(area);
        alert.showAndWait();
    }

    @FXML
    private void handleDownload() {
        String path = currentAnnouncement.getAttachment_path();
        if (path == null || path.isEmpty()) return;
        new Thread(() -> {
            try {
                String cleanPath = path.startsWith("/") ? path.substring(1) : path;
                URL url = new URL(com.frontenddesktop.config.AppConfig.resolve(cleanPath));
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    return;
                }

                File tempFile = File.createTempFile("announcement_", "_" + new File(cleanPath).getName());
                tempFile.deleteOnExit();
                try (InputStream in = conn.getInputStream();
                     FileOutputStream out = new FileOutputStream(tempFile)) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                }

                Desktop.getDesktop().open(tempFile);
            } catch (Exception e) { e.printStackTrace(); }
        }).start();
    }
}

