package com.frontenddesktop.service;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import com.google.gson.JsonArray;
import com.google.gson.JsonParser;
import javafx.application.Platform;
import javafx.scene.control.Alert;
import java.util.Timer;
import java.util.TimerTask;

public class NotificationService {
    private Timer timer;

    public void startChecking() {
        timer = new Timer(true);
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                checkForUpdates();
            }
        }, 0, 60000); // Check every 60 seconds [cite: 2026-01-21]
    }

    private void checkForUpdates() {
        try {
            String url = "http://localhost:8080/backend-web/api/check_notifications.jsp?dept_head_id=" + UserSession.getUserId();
            String response = HttpConnector.get(url);

            JsonArray jsonArray = JsonParser.parseString(response).getAsJsonArray();

            if (jsonArray.size() > 0) {
                Platform.runLater(() -> {
                    showToast("New Task Update", "A staff member has replied to: " + jsonArray.get(0).getAsJsonObject().get("title").getAsString());
                });
            }
        } catch (Exception e) {
            System.err.println("Notification check failed: " + e.getMessage());
        }
    }

    private void showToast(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText("Action Required");
        alert.setContentText(message);
        alert.show();
    }
}