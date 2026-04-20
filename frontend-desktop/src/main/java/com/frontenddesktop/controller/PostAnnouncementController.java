package com.frontenddesktop.controller;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class PostAnnouncementController {

    @FXML private TextField titleField;
    @FXML private TextArea contentArea;
    @FXML private Label lblFileName;

    private File selectedFile;

    /**
     * Opens a file chooser to select an attachment for the announcement
     * Supports visuals for creative Gospel sharing missions [cite: 2026-02-13]
     */
    @FXML
    private void handleFileSelection() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Select Announcement Attachment");

        // Filter for common office and media files [cite: 2026-01-21]
        fileChooser.getExtensionFilters().addAll(
                new FileChooser.ExtensionFilter("All Files", "*.pdf", "*.docx", "*.xlsx", "*.png", "*.jpg", "*.mp4", "*.mp3")
        );

        selectedFile = fileChooser.showOpenDialog(titleField.getScene().getWindow());

        if (selectedFile != null) {
            lblFileName.setText(selectedFile.getName());
        }
    }

    /**
     * Logic to broadcast the announcement to the database
     */
    @FXML
    private void handlePost() {
        String title = titleField.getText().trim();
        String content = contentArea.getText().trim();

        if (title.isEmpty() || content.isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Required Fields", "Please provide both a title and content.");
            return;
        }

        // Parameters mapped directly to your database columns
        Map<String, String> data = new HashMap<>();
        data.put("poster_id", String.valueOf(UserSession.getUserId()));
        data.put("title", title);
        data.put("content", content);
        data.put("target_dept", UserSession.getUserDept()); // Matches your schema

        new Thread(() -> {
            try {
                String response = (selectedFile != null)
                        ? HttpConnector.postMultipart("http://localhost:8080/backend-web/api/announcements.jsp", data, selectedFile)
                        : HttpConnector.post("http://localhost:8080/backend-web/api/announcements.jsp", data);

                Platform.runLater(() -> {
                    // Check for standard success status
                    if (response != null && response.contains("\"status\":\"success\"")) {
                        showAlert(Alert.AlertType.INFORMATION, "Broadcast Success", "Announcement sent.");
                        handleCancel();
                    } else {
                        // Extracting the server message helps debug the "Server failed" popup
                        showAlert(Alert.AlertType.ERROR, "Broadcast Failed", "Server Error. Check database connectivity.");
                    }
                });
            } catch (Exception e) {
                Platform.runLater(() -> showAlert(Alert.AlertType.ERROR, "Network Error", "Connection failed."));
            }
        }).start();
    }

    @FXML
    private void handleCancel() {
        ((Stage) titleField.getScene().getWindow()).close();
    }

    private void showAlert(Alert.AlertType type, String title, String msg) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(msg);
        alert.showAndWait();
    }
}
