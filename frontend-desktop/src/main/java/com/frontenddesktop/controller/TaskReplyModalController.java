package com.frontenddesktop.controller;

import com.frontenddesktop.model.Task;
import com.frontenddesktop.network.HttpConnector;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class TaskReplyModalController {

    @FXML private TextArea replyArea;
    @FXML private Label lblFileName;

    private Task currentTask;
    private File selectedCompletionFile;

    /**
     * Receives the task object from the TaskItemController
     */
    public void setTask(Task task) {
        this.currentTask = task;
    }

    /**
     * Staff selects the finished file for submission
     */
    @FXML
    private void handleFileSelect() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Upload Finished Work");
        // Filter for office documents common in university projects
        fileChooser.getExtensionFilters().addAll(
                new FileChooser.ExtensionFilter("Documents", "*.pdf", "*.docx", "*.xlsx", "*.zip")
        );

        selectedCompletionFile = fileChooser.showOpenDialog(replyArea.getScene().getWindow());

        if (selectedCompletionFile != null) {
            lblFileName.setText(selectedCompletionFile.getName());
            lblFileName.setStyle("-fx-text-fill: #27ae60; -fx-font-weight: bold;");
        }
    }

    /**
     * Submits the work and updates the task status to 'Completed'
     */
    @FXML
    private void handleSubmit() {
        String replyText = replyArea.getText().trim();

        if (replyText.isEmpty()) {
            showAlert("Validation Error", "Please provide comments regarding your submission.");
            return;
        }

        // Aligning keys with tasks.jsp and Task.java @SerializedName
        Map<String, String> params = new HashMap<>();
        params.put("action", "staff_reply"); // Important for backend routing
        params.put("task_id", String.valueOf(currentTask.getTaskId()));
        params.put("staff_reply_text", replyText);
        params.put("status", "Completed");

        new Thread(() -> {
            try {
                String url = "http://localhost:8080/backend-web/api/tasks.jsp";
                String response = (selectedCompletionFile != null)
                        ? HttpConnector.postMultipart(url, params, selectedCompletionFile)
                        : HttpConnector.post(url, params);

                Platform.runLater(() -> {
                    if (response != null && response.contains("success")) {
                        // Success: Close and the Dashboard list should be refreshed by the parent
                        ((Stage) replyArea.getScene().getWindow()).close();
                    } else {
                        showAlert("Submission Failed", "The server rejected the update. Please check your connection.");
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> showAlert("Network Error", "Could not connect to the backend server."));
            }
        }).start();
    }

    @FXML
    private void handleCancel() {
        ((Stage) replyArea.getScene().getWindow()).close();
    }

    private void showAlert(String title, String content) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(content);
        alert.showAndWait();
    }
}
