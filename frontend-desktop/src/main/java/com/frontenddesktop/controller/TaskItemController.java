package com.frontenddesktop.controller;

import com.frontenddesktop.model.Task;
import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextArea;
import javafx.scene.control.Tooltip;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.awt.Desktop;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class TaskItemController {
    @FXML private Label lblTitle;
    @FXML private Label lblPriority;
    @FXML private Label lblDueDate;
    @FXML private Label lblDescription;
    @FXML private Button btnDownload;
    @FXML private Button btnReply;
    @FXML private Button btnView;
    @FXML private ComboBox<String> statusCombo;
    @FXML private HBox deptHeadControls;

    private Task currentTask;
    private Runnable onTaskChanged;

    public void setData(Task task) {
        setData(task, null);
    }

    public void setData(Task task, Runnable onTaskChanged) {
        this.currentTask = task;
        this.onTaskChanged = onTaskChanged;
        lblTitle.setText(task.getTitle());
        lblPriority.setText(task.getPriority().toUpperCase());
        lblDueDate.setText("Due: " + task.getDueDate());

        String desc = task.getDescription();
        boolean hasLongDescription = desc != null && !desc.trim().isEmpty() && desc.length() > 80;
        if (desc != null && !desc.trim().isEmpty()) {
            lblDescription.setText(desc);
        } else {
            lblDescription.setText("No instructions provided.");
        }
        btnView.setVisible(hasLongDescription);
        btnView.setManaged(hasLongDescription);

        updatePriorityStyle(task.getPriority());

        statusCombo.getItems().setAll("Pending", "In Progress", "Completed");
        statusCombo.setValue(task.getStatus());

        String role = UserSession.getRole();
        boolean isDeptHead = "Dept Head".equalsIgnoreCase(role);

        deptHeadControls.setVisible(isDeptHead);
        deptHeadControls.setManaged(isDeptHead);

        if ("Staff".equalsIgnoreCase(role)) {
            statusCombo.setDisable(false);
            btnReply.setText("Reply");
            btnReply.setVisible(true);
            btnReply.setManaged(true);
            btnReply.setStyle("-fx-background-color: #eef2ff; -fx-text-fill: #4338ca; -fx-font-size: 12px; -fx-font-weight: bold; -fx-background-radius: 6; -fx-padding: 6 10;");
            statusCombo.setOnAction(e -> updateStatus(statusCombo.getValue()));
        } else if (isDeptHead) {
            statusCombo.setDisable(true);
            boolean canReview = "Completed".equalsIgnoreCase(task.getStatus())
                    && task.getAcknowledged() == 0
                    && task.getCreatorId() == UserSession.getUserId();
            btnReply.setText("Review");
            btnReply.setVisible(canReview);
            btnReply.setManaged(canReview);
            if (canReview) {
                btnReply.setStyle("-fx-background-color: #dcfce7; -fx-text-fill: #166534; -fx-font-size: 12px; -fx-font-weight: bold; -fx-background-radius: 6; -fx-padding: 6 10;");
            }
        } else {
            statusCombo.setDisable(true);
            btnReply.setVisible(false);
            btnReply.setManaged(false);
        }
    }

    @FXML
    private void handleEditTask() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/TaskModal.fxml"));
            Parent root = loader.load();

            TaskModalController controller = loader.getController();
            controller.setTaskData(currentTask);

            Stage stage = new Stage();
            stage.setTitle("Edit Task: " + currentTask.getTitle());
            stage.initModality(Modality.APPLICATION_MODAL);
            stage.setScene(new Scene(root));
            stage.showAndWait();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void handleDeleteTask() {
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
        confirm.setTitle("Delete Task");
        confirm.setHeaderText("Are you sure you want to delete this task?");
        confirm.setContentText("Task: " + currentTask.getTitle());

        if (confirm.showAndWait().orElse(ButtonType.CANCEL) == ButtonType.OK) {
            new Thread(() -> {
                try {
                    Map<String, String> params = new HashMap<>();
                    params.put("action", "delete_task");
                    params.put("task_id", String.valueOf(currentTask.getTaskId()));

                    String response = HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("tasks.jsp"), params);
                    if (response != null && response.contains("success")) {
                        Platform.runLater(() -> {
                            if (onTaskChanged != null) {
                                onTaskChanged.run();
                            } else {
                                VBox container = (VBox) deptHeadControls.getScene().lookup("#taskContainer");
                                if (container != null) {
                                    container.getChildren().remove(deptHeadControls.getParent().getParent());
                                }
                            }
                        });
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }

    @FXML
    private void handleViewFullDescription() {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Task Instructions");
        alert.setHeaderText("Full Details: " + currentTask.getTitle());

        TextArea textArea = new TextArea(currentTask.getDescription());
        textArea.setEditable(false);
        textArea.setWrapText(true);
        textArea.setPrefHeight(300);
        textArea.setPrefWidth(450);

        alert.getDialogPane().setContent(textArea);
        alert.showAndWait();
    }

    @FXML
    private void handleDownload() {
        String path = resolveDownloadPath();

        if (path == null || path.isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "No File", "No attachment associated with this task.");
            return;
        }

        new Thread(() -> {
            try {
                String cleanPath = path.startsWith("/") ? path.substring(1) : path;
                URL url = new URL(com.frontenddesktop.config.AppConfig.resolve(cleanPath));
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
                    File tempFile = File.createTempFile("task_attachment_", "_" + new File(cleanPath).getName());
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
                } else {
                    showAlert(Alert.AlertType.ERROR, "Error", "Attachment is not available on the server.");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    private String resolveDownloadPath() {
        String initialPath = currentTask.getInitialAttachmentPath();
        if (initialPath != null && !initialPath.isBlank()) {
            return initialPath;
        }

        String completionPath = currentTask.getCompletionAttachmentPath();
        if (completionPath != null && !completionPath.isBlank()) {
            return completionPath;
        }

        return "";
    }

    private void notifyTaskChanged() {
        if (onTaskChanged != null) {
            onTaskChanged.run();
        }
    }

    @FXML
    private void handleReply() {
        try {
            String role = UserSession.getRole();
            boolean isReview = "Dept Head".equalsIgnoreCase(role);
            String fxmlPath = isReview ? "/com/frontenddesktop/view/TaskModal.fxml" : "/com/frontenddesktop/view/TaskReplyModal.fxml";

            FXMLLoader loader = new FXMLLoader(getClass().getResource(fxmlPath));
            Parent root = loader.load();

            if (isReview) {
                TaskModalController controller = loader.getController();
                controller.setTaskData(currentTask);
                controller.setOnTaskUpdated(this::notifyTaskChanged);
            } else {
                TaskReplyModalController controller = loader.getController();
                controller.setTask(currentTask);
            }

            Stage stage = new Stage();
            stage.setTitle(isReview ? "Review Submission" : "Submit Work");
            stage.initModality(Modality.APPLICATION_MODAL);
            stage.setScene(new Scene(root));
            stage.showAndWait();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void updateStatus(String newStatus) {
        new Thread(() -> {
            try {
                Map<String, String> params = new HashMap<>();
                params.put("action", "update_status");
                params.put("task_id", String.valueOf(currentTask.getTaskId()));
                params.put("status", newStatus);
                HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("tasks.jsp"), params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    private void updatePriorityStyle(String priority) {
        String color = switch (priority.toLowerCase()) {
            case "high", "urgent" -> "#e74c3c";
            case "medium" -> "#f39c12";
            default -> "#2ecc71";
        };
        lblPriority.setStyle("-fx-background-color: " + color + "; -fx-text-fill: white; -fx-padding: 2 6; -fx-background-radius: 999;");
    }

    private void showAlert(Alert.AlertType type, String title, String content) {
        Platform.runLater(() -> {
            Alert alert = new Alert(type);
            alert.setTitle(title);
            alert.setHeaderText(null);
            alert.setContentText(content);
            alert.showAndWait();
        });
    }
}

