package com.frontenddesktop.controller;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.geometry.Rectangle2D;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.ButtonBar;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.Dialog;
import javafx.scene.control.DialogPane;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.GridPane;
import javafx.stage.Screen;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class LoginController {
    @FXML private TextField usernameField;
    @FXML private PasswordField passwordField;
    @FXML private TextField passwordTextField;
    @FXML private Button showPasswordButton;
    @FXML private Button loginButton;

    @FXML
    public void initialize() {
        usernameField.setOnKeyPressed(event -> {
            if (event.getCode() == KeyCode.ENTER) handleLogin();
        });
        passwordField.setOnKeyPressed(event -> {
            if (event.getCode() == KeyCode.ENTER) handleLogin();
        });
        passwordTextField.setOnKeyPressed(event -> {
            if (event.getCode() == KeyCode.ENTER) handleLogin();
        });
    }

    @FXML
    private void togglePasswordVisibility() {
        if (passwordField.isVisible()) {
            passwordTextField.setText(passwordField.getText());
            passwordTextField.setVisible(true);
            passwordField.setVisible(false);
            showPasswordButton.setText("Hide");
        } else {
            passwordField.setText(passwordTextField.getText());
            passwordField.setVisible(true);
            passwordTextField.setVisible(false);
            showPasswordButton.setText("Show");
        }
    }

    @FXML
    private void handleLogin() {
        String user = usernameField.getText();
        String pass = passwordField.isVisible() ? passwordField.getText() : passwordTextField.getText();

        if (user.isEmpty() || pass.isEmpty()) {
            showAlert(Alert.AlertType.ERROR, "Error", "Please enter username and password.");
            return;
        }

        new Thread(() -> {
            try {
                HttpConnector.clearSession();
                Map<String, String> params = new HashMap<>();
                params.put("user", user);
                params.put("pass", pass);
                String response = HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("auth.jsp"), params);

                javafx.application.Platform.runLater(() -> {
                    if (response != null && response.contains("\"success\":true")) {
                        JsonObject jsonResponse = JsonParser.parseString(response).getAsJsonObject();
                        int dbUserId = jsonResponse.get("user_id").getAsInt();
                        String role = jsonResponse.get("role").getAsString();

                        if (dbUserId <= 0) {
                            showAlert(Alert.AlertType.ERROR, "Auth Error", "Server returned an invalid User ID.");
                            return;
                        }

                        if ("Admin".equalsIgnoreCase(role)) {
                            HttpConnector.clearSession();
                            showAlert(
                                    Alert.AlertType.INFORMATION,
                                    "Web Portal Required",
                                    "Admin accounts must use the web admin portal.\n\nOpen: " + com.frontenddesktop.config.AppConfig.adminUrl("login.jsp")
                            );
                            return;
                        }

                        UserSession.init(
                                dbUserId,
                                jsonResponse.get("username").getAsString(),
                                role,
                                jsonResponse.get("department").getAsString(),
                                jsonResponse.get("full_name").getAsString(),
                                jsonResponse.has("profile_pic_path") && !jsonResponse.get("profile_pic_path").isJsonNull()
                                        ? jsonResponse.get("profile_pic_path").getAsString()
                                        : null,
                                jsonResponse.has("phone") && !jsonResponse.get("phone").isJsonNull()
                                        ? jsonResponse.get("phone").getAsString()
                                        : "",
                                jsonResponse.has("bio") && !jsonResponse.get("bio").isJsonNull()
                                        ? jsonResponse.get("bio").getAsString()
                                        : "",
                                jsonResponse.has("personal_email") && !jsonResponse.get("personal_email").isJsonNull()
                                        ? jsonResponse.get("personal_email").getAsString()
                                        : ""
                        );

                        navigateToDashboard();
                    } else {
                        showAlert(Alert.AlertType.ERROR, "Access Denied", "Invalid credentials.");
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                javafx.application.Platform.runLater(() ->
                        showAlert(Alert.AlertType.WARNING, "Connection Error", "Could not connect to server.")
                );
            }
        }).start();
    }

    @FXML
    private void handleForgotPassword() {
        Dialog<ButtonType> dialog = new Dialog<>();
        dialog.setTitle("Forgot Password");
        dialog.setHeaderText("Request a password reset link");

        ButtonType sendButtonType = new ButtonType("Send Reset Link", ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().addAll(sendButtonType, ButtonType.CANCEL);

        TextField resetUsernameField = new TextField();
        resetUsernameField.setPromptText("Username");
        resetUsernameField.setText(usernameField.getText() != null ? usernameField.getText().trim() : "");

        TextField resetEmailField = new TextField();
        resetEmailField.setPromptText("Personal email");

        Label note = new Label("Use the personal email saved in your profile. The reset link will open in a browser.");
        note.setWrapText(true);
        note.setStyle("-fx-text-fill: #64748b; -fx-font-size: 12px;");

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(12);
        grid.setPadding(new Insets(10, 0, 0, 0));
        grid.add(new Label("Username"), 0, 0);
        grid.add(resetUsernameField, 1, 0);
        grid.add(new Label("Personal Email"), 0, 1);
        grid.add(resetEmailField, 1, 1);
        grid.add(note, 0, 2, 2, 1);

        dialog.getDialogPane().setContent(grid);
        dialog.getDialogPane().setStyle("-fx-font-family: 'Segoe UI'; -fx-font-size: 14px;");

        dialog.showAndWait().ifPresent(result -> {
            if (result != sendButtonType) {
                return;
            }

            String username = resetUsernameField.getText() != null ? resetUsernameField.getText().trim() : "";
            String personalEmail = resetEmailField.getText() != null ? resetEmailField.getText().trim() : "";

            if (username.isEmpty() || personalEmail.isEmpty()) {
                showAlert(Alert.AlertType.WARNING, "Missing Information", "Enter your username and personal email.");
                return;
            }

            new Thread(() -> {
                try {
                    Map<String, String> params = new HashMap<>();
                    params.put("username", username);
                    params.put("personal_email", personalEmail);

                    String response = HttpConnector.post(com.frontenddesktop.config.AppConfig.apiUrl("request_password_reset.jsp"), params);
                    javafx.application.Platform.runLater(() -> {
                        if (response != null && response.trim().startsWith("{")) {
                            JsonObject jsonResponse = JsonParser.parseString(response).getAsJsonObject();
                            boolean success = jsonResponse.has("success") && jsonResponse.get("success").getAsBoolean();
                            String message = jsonResponse.has("message")
                                    ? jsonResponse.get("message").getAsString()
                                    : "If the username and personal email match an account, a reset link has been sent.";

                            showAlert(success ? Alert.AlertType.INFORMATION : Alert.AlertType.ERROR,
                                    success ? "Reset Requested" : "Reset Request Failed",
                                    message);
                        } else {
                            showAlert(Alert.AlertType.ERROR, "Reset Request Failed", "The server returned an invalid response.");
                        }
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                    javafx.application.Platform.runLater(() ->
                            showAlert(Alert.AlertType.ERROR, "Connection Error", "Could not submit the reset request.")
                    );
                }
            }).start();
        });
    }

    private void navigateToDashboard() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/Dashboard.fxml"));
            Parent root = loader.load();

            Stage loginStage = (Stage) usernameField.getScene().getWindow();
            loginStage.close();

            Stage dashboardStage = new Stage();
            dashboardStage.initStyle(StageStyle.DECORATED);

            Scene scene = new Scene(root, 1100, 750);

            URL cssPath = getClass().getResource("/com/frontenddesktop/styles/style.css");
            if (cssPath != null) {
                scene.getStylesheets().add(cssPath.toExternalForm());
            }

            dashboardStage.setScene(scene);
            dashboardStage.setTitle("University Dashboard - " + UserSession.getRole());
            dashboardStage.setResizable(true);

            Rectangle2D visualBounds = Screen.getPrimary().getVisualBounds();
            dashboardStage.setX(visualBounds.getMinX());
            dashboardStage.setY(visualBounds.getMinY());
            dashboardStage.setWidth(visualBounds.getWidth());
            dashboardStage.setHeight(visualBounds.getHeight());
            dashboardStage.setMinWidth(1100);
            dashboardStage.setMinHeight(750);
            dashboardStage.setMaximized(true);

            dashboardStage.setOnCloseRequest(e -> {
                javafx.application.Platform.exit();
                System.exit(0);
            });

            dashboardStage.show();

        } catch (IOException e) {
            e.printStackTrace();
            javafx.application.Platform.runLater(() ->
                    showAlert(Alert.AlertType.ERROR, "UI Error", "Could not load Dashboard.")
            );
        }
    }

    private void showAlert(Alert.AlertType type, String title, String msg) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(msg);
        alert.showAndWait();
    }
}


