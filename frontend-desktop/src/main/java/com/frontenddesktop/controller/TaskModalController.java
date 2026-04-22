package com.frontenddesktop.controller;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.model.Task;
import com.frontenddesktop.model.User;
import com.frontenddesktop.network.HttpConnector;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import javafx.util.StringConverter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TaskModalController {
    @FXML private Label headerLabel, lblFileName, lblStaffReply, lblSubmissionFileName;
    @FXML private TextField titleField;
    @FXML private ComboBox<User> staffComboBox;
    @FXML private ComboBox<String> priorityComboBox;
    @FXML private DatePicker dueDatePicker;
    @FXML private TextArea descArea;
    @FXML private VBox reviewSection, creationAttachmentBox;
    @FXML private Button btnSaveTask, btnAcknowledge;

    private File selectedFile;
    private Task currentTask;
    private boolean isEditMode = false;
    private Runnable onTaskUpdated;

    @FXML
    public void initialize() {
        priorityComboBox.getItems().setAll("Low", "Medium", "High", "Urgent");
        priorityComboBox.setValue("Medium");

        // --- Visual Guardrail: Disable past dates in the calendar picker ---
        dueDatePicker.setDayCellFactory(picker -> new DateCell() {
            @Override
            public void updateItem(LocalDate date, boolean empty) {
                super.updateItem(date, empty);
                // Disable dates before today
                setDisable(empty || date.isBefore(LocalDate.now()));
                if (date.isBefore(LocalDate.now())) {
                    setStyle("-fx-background-color: #f1f2f6; -fx-text-fill: #a2a8d3;");
                }
            }
        });

        setupStaffComboBox();
        loadStaffMembers();
    }

    private void setupStaffComboBox() {
        staffComboBox.setConverter(new StringConverter<User>() {
            @Override
            public String toString(User user) { return (user == null) ? "" : user.getUsername(); }
            @Override
            public User fromString(String string) { return null; }
        });
    }

    public void setTaskData(Task task) {
        this.currentTask = task;
        if ("Completed".equalsIgnoreCase(task.getStatus())) {
            setupReviewMode(task);
        } else {
            setupEditMode(task);
        }
    }

    public void setOnTaskUpdated(Runnable onTaskUpdated) {
        this.onTaskUpdated = onTaskUpdated;
    }

    private void setupEditMode(Task task) {
        this.isEditMode = true;
        headerLabel.setText("Edit Task Details");
        btnSaveTask.setText("Update Task");

        titleField.setText(task.getTitle());
        descArea.setText(task.getDescription());
        priorityComboBox.setValue(task.getPriority());

        if (task.getDueDate() != null) {
            dueDatePicker.setValue(LocalDate.parse(task.getDueDate()));
        }

        Platform.runLater(() -> {
            for (User u : staffComboBox.getItems()) {
                if (u.getId() == task.getAssigneeId()) {
                    staffComboBox.setValue(u);
                    break;
                }
            }
        });
    }

    private void setupReviewMode(Task task) {
        headerLabel.setText("Review Staff Submission");
        titleField.setText(task.getTitle());
        titleField.setEditable(false);
        descArea.setText(task.getDescription());
        descArea.setEditable(false);
        priorityComboBox.setDisable(true);
        dueDatePicker.setDisable(true);
        staffComboBox.setDisable(true);

        creationAttachmentBox.setVisible(false);
        creationAttachmentBox.setManaged(false);
        reviewSection.setVisible(true);
        reviewSection.setManaged(true);
        btnSaveTask.setVisible(false);
        btnSaveTask.setManaged(false);
        btnAcknowledge.setVisible(true);
        btnAcknowledge.setManaged(true);

        lblStaffReply.setText(task.getStaffReplyText() != null ? task.getStaffReplyText() : "No message provided.");
        if (task.getCompletionAttachmentPath() != null && !task.getCompletionAttachmentPath().isEmpty()) {
            lblSubmissionFileName.setText(new File(task.getCompletionAttachmentPath()).getName());
        }
    }

    @FXML
    private void handleSaveTask() {
        User selectedStaff = staffComboBox.getValue();
        String title = titleField.getText();
        LocalDate selectedDate = dueDatePicker.getValue();

        // 1. Mandatory Fields Validation
        if (selectedStaff == null || title.isEmpty() || selectedDate == null) {
            showAlert(Alert.AlertType.WARNING, "Validation Error", "Please fill in all required fields.");
            return;
        }

        // 2. Mission Guardrail: Date Validation [cite: 2026-02-13]
        // Only enforce future dates for new tasks (Edits might already have an old date)
        if (!isEditMode && selectedDate.isBefore(LocalDate.now())) {
            showAlert(Alert.AlertType.ERROR, "Invalid Date", "The due date cannot be in the past.");
            return;
        }

        Map<String, String> taskData = new HashMap<>();
        taskData.put("action", isEditMode ? "edit_task" : "create_task");
        if (isEditMode) {
            taskData.put("task_id", String.valueOf(currentTask.getTaskId()));
        }

        taskData.put("title", title);
        taskData.put("description", descArea.getText());
        taskData.put("priority", priorityComboBox.getValue());
        taskData.put("due_date", selectedDate.toString());
        taskData.put("assignee_id", String.valueOf(selectedStaff.getId()));
        taskData.put("creator_id", String.valueOf(UserSession.getUserId()));

        String successMsg = isEditMode ? "Task updated successfully!" : "Task assigned successfully!";
        sendRequest(com.frontenddesktop.config.AppConfig.apiUrl("tasks.jsp"), taskData, selectedFile, successMsg);
    }

    private void loadStaffMembers() {
        new Thread(() -> {
            try {
                String url = com.frontenddesktop.config.AppConfig.resolve("api/users.jsp?dept_head_id=") + UserSession.getUserId();
                String response = HttpConnector.get(url);
                if (response != null && response.trim().startsWith("[")) {
                    List<User> staffList = new Gson().fromJson(response, new TypeToken<List<User>>(){}.getType());
                    Platform.runLater(() -> {
                        staffComboBox.getItems().setAll(staffList);
                        // If we are in edit mode, re-trigger the selection logic once list is loaded
                        if (isEditMode && currentTask != null) {
                            for (User u : staffList) {
                                if (u.getId() == currentTask.getAssigneeId()) {
                                    staffComboBox.setValue(u);
                                    break;
                                }
                            }
                        }
                    });
                }
            } catch (Exception e) { e.printStackTrace(); }
        }).start();
    }

    private void sendRequest(String url, Map<String, String> data, File uploadFile, String successMsg) {
        new Thread(() -> {
            try {
                String response = (uploadFile != null)
                        ? HttpConnector.postMultipart(url, data, uploadFile)
                        : HttpConnector.post(url, data);
                Platform.runLater(() -> {
                    if (response != null && response.contains("success")) {
                        showAlert(Alert.AlertType.INFORMATION, "Success", successMsg);
                        if (onTaskUpdated != null) {
                            onTaskUpdated.run();
                        }
                        handleCancel();
                    } else {
                        showAlert(Alert.AlertType.ERROR, "Error", extractErrorMessage(response));
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() ->
                        showAlert(Alert.AlertType.ERROR, "Request Failed", "Could not complete the task action.")
                );
            }
        }).start();
    }

    private String extractErrorMessage(String response) {
        if (response == null || response.isBlank()) {
            return "Server failed to process request.";
        }

        try {
            JsonObject json = JsonParser.parseString(response).getAsJsonObject();
            if (json.has("message") && !json.get("message").isJsonNull()) {
                String message = json.get("message").getAsString();
                if (!message.isBlank()) {
                    return message;
                }
            }
        } catch (Exception ignored) {
        }

        return "Server failed to process request.";
    }

    @FXML private void handleFileSelection() {
        FileChooser fc = new FileChooser();
        selectedFile = fc.showOpenDialog(headerLabel.getScene().getWindow());
        if (selectedFile != null) lblFileName.setText(selectedFile.getName());
    }

    @FXML private void handleCancel() { ((Stage) headerLabel.getScene().getWindow()).close(); }

    private void showAlert(Alert.AlertType type, String title, String msg) {
        Platform.runLater(() -> {
            Alert a = new Alert(type);
            a.setTitle(title); a.setHeaderText(null); a.setContentText(msg); a.showAndWait();
        });
    }
    @FXML
    private void handleAcknowledge() {
        if (currentTask == null) return;

        Map<String, String> params = new HashMap<>();
        params.put("task_id", String.valueOf(currentTask.getTaskId()));

        String url = com.frontenddesktop.config.AppConfig.apiUrl("acknowledge_task.jsp");
        sendRequest(url, params, null, "Task successfully acknowledged and closed!");
    }
    @FXML
    private void handleDownloadSubmission() {
        if (currentTask != null) openFile(currentTask.getCompletionAttachmentPath());
    }

    private void openFile(String path) {
        if (path == null || path.isBlank()) {
            return;
        }

        new Thread(() -> {
            try {
                String cleanPath = path.startsWith("/") ? path.substring(1) : path;
                URL url = new URL(com.frontenddesktop.config.AppConfig.resolve(cleanPath));
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    showAlert(Alert.AlertType.ERROR, "Download Error", "Attachment is not available on the server.");
                    return;
                }

                String fileName = new File(cleanPath).getName();
                File tempFile = File.createTempFile("task_", "_" + fileName);
                tempFile.deleteOnExit();
                try (InputStream in = conn.getInputStream();
                     FileOutputStream out = new FileOutputStream(tempFile)) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                }

                java.awt.Desktop.getDesktop().open(tempFile);
            } catch (Exception e) {
                e.printStackTrace();
                showAlert(Alert.AlertType.ERROR, "Download Error", "Could not open the attachment.");
            }
        }).start();
    }
}

