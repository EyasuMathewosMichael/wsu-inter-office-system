package com.frontenddesktop.controller;

import com.frontenddesktop.model.Announcement;
import com.frontenddesktop.model.Task;
import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import com.frontenddesktop.util.ProfileImageUtil;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Circle;
import javafx.scene.text.Text;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.stream.Collectors;

public class DashboardController {
    @FXML private Text txtUserName;
    @FXML private Text txtUserRole;
    @FXML private Text txtSidebarAvatarInitials;
    @FXML private Label lblGreeting;
    @FXML private Label lblOverviewSubtitle;
    @FXML private Label lblUserDept;
    @FXML private Label lblTaskCount;
    @FXML private Label lblAnnouncementCount;
    @FXML private Label lblTaskCardTitle;
    @FXML private Label lblAnnouncementCardTitle;
    @FXML private Label lblDepartmentCardTitle;
    @FXML private Label lblTasksHeading;
    @FXML private Label lblTasksSubtitle;
    @FXML private Label lblAnnouncementsHeading;
    @FXML private Label lblAnnouncementsSubtitle;
    @FXML private Button btnCreateTask;
    @FXML private Button btnPostAnnouncement;
    @FXML private VBox announcementContainer;
    @FXML private VBox taskContainer;
    @FXML private ScrollPane overviewPane;
    @FXML private ScrollPane taskOverviewPane;
    @FXML private ScrollPane announcementOverviewPane;
    @FXML private StackPane contentArea;
    @FXML private TextField searchField;
    @FXML private Circle chatNotificationDot;
    @FXML private Button btnTasks;
    @FXML private Button btnSidebarTasks;
    @FXML private Button btnSidebarAnnouncements;
    @FXML private Button btnChat;
    @FXML private Button btnProfile;
    @FXML private Button logoutBtn;
    @FXML private ImageView imgSidebarAvatar;

    private List<Announcement> allAnnouncements = new ArrayList<>();
    private Timer notificationTimer;
    private enum SectionView { OVERVIEW, TASKS, ANNOUNCEMENTS, CHAT, PROFILE }
    private SectionView currentSection = SectionView.OVERVIEW;

    @FXML
    public void initialize() {
        refreshUserIdentity();
        applyRoleDashboardCopy();

        boolean isDeptHead = "Dept Head".equalsIgnoreCase(UserSession.getRole());
        if (btnCreateTask != null) btnCreateTask.setVisible(isDeptHead);
        if (btnPostAnnouncement != null) btnPostAnnouncement.setVisible(isDeptHead);

        if (chatNotificationDot != null) {
            chatNotificationDot.setVisible(false);
        }

        if (searchField != null) {
            searchField.textProperty().addListener((obs, oldVal, newVal) -> filterAnnouncements(newVal));
        }

        Platform.runLater(() -> {
            if (btnTasks != null && btnTasks.getScene() != null) {
                setActiveButton(btnTasks);
            }
        });

        showPrimaryPane(overviewPane);
        loadOverviewData();
        startNotificationPolling();
    }

    private void refreshUserIdentity() {
        String fullName = UserSession.getFullName();
        if (fullName == null || fullName.isBlank()) {
            fullName = UserSession.getUsername();
        }

        txtUserName.setText(fullName != null ? fullName : "User");
        txtUserRole.setText(UserSession.getRole() + " | ID: " + UserSession.getUserId());
        lblUserDept.setText(UserSession.getUserDept());
        lblGreeting.setText("Welcome Back, " + (fullName != null ? fullName : "User"));
        refreshSidebarAvatar();
    }

    private void applyRoleDashboardCopy() {
        String role = UserSession.getRole() != null ? UserSession.getRole().trim() : "";
        boolean isDeptHead = "Dept Head".equalsIgnoreCase(role);

        if (lblOverviewSubtitle != null) {
            lblOverviewSubtitle.setText(isDeptHead
                    ? "Track team workload, publish updates, and oversee department progress."
                    : "Stay on top of your assigned work and the latest department updates.");
        }

        if (lblTaskCardTitle != null) {
            lblTaskCardTitle.setText(isDeptHead ? "Open Team Tasks" : "My Active Tasks");
        }

        if (lblAnnouncementCardTitle != null) {
            lblAnnouncementCardTitle.setText(isDeptHead ? "Published Updates" : "Unread Updates");
        }

        if (lblDepartmentCardTitle != null) {
            lblDepartmentCardTitle.setText(isDeptHead ? "Managed Department" : "My Department");
        }

        if (lblTasksHeading != null) {
            lblTasksHeading.setText(isDeptHead ? "Department Tasks" : "My Tasks");
        }

        if (lblTasksSubtitle != null) {
            lblTasksSubtitle.setText(isDeptHead
                    ? "Create, assign, and review tasks for your department staff."
                    : "Follow your assignments, update statuses, and submit your work.");
        }

        if (lblAnnouncementsHeading != null) {
            lblAnnouncementsHeading.setText(isDeptHead ? "Department Announcements" : "Department Updates");
        }

        if (lblAnnouncementsSubtitle != null) {
            lblAnnouncementsSubtitle.setText(isDeptHead
                    ? "Publish and manage announcements for your department."
                    : "Read the latest announcements shared with your department.");
        }
    }

    private void refreshSidebarAvatar() {
        if (txtSidebarAvatarInitials == null || imgSidebarAvatar == null) {
            return;
        }

        txtSidebarAvatarInitials.setText(generateInitials(UserSession.getFullName()));
        txtSidebarAvatarInitials.setVisible(true);
        imgSidebarAvatar.setVisible(false);
        imgSidebarAvatar.setClip(new Circle(35, 35, 35));

        String imageUrl = ProfileImageUtil.buildProfileImageUrl(UserSession.getProfilePhotoPath());
        if (imageUrl == null) {
            return;
        }

        Image image = new Image(imageUrl, 70, 70, false, true, true);
        image.errorProperty().addListener((obs, wasError, isError) -> {
            if (Boolean.TRUE.equals(isError)) {
                Platform.runLater(() -> {
                    imgSidebarAvatar.setVisible(false);
                    txtSidebarAvatarInitials.setVisible(true);
                });
            }
        });
        image.progressProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue.doubleValue() >= 1.0 && !image.isError()) {
                showSidebarImage(image);
            }
        });
        imgSidebarAvatar.setImage(image);
        if (image.getProgress() >= 1.0 && !image.isError()) {
            showSidebarImage(image);
        }
    }

    private void showSidebarImage(Image image) {
        Platform.runLater(() -> {
            imgSidebarAvatar.setImage(image);
            imgSidebarAvatar.setVisible(true);
            txtSidebarAvatarInitials.setVisible(false);
        });
    }

    private String generateInitials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "??";
        }

        String[] parts = name.trim().split("\\s+");
        if (parts.length >= 2) {
            return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
        }
        return parts[0].substring(0, Math.min(parts[0].length(), 2)).toUpperCase();
    }

    private void setActiveButton(Button activeBtn) {
        clearActiveState(btnTasks);
        clearActiveState(btnSidebarTasks);
        clearActiveState(btnSidebarAnnouncements);
        clearActiveState(btnChat);
        clearActiveState(btnProfile);

        if (activeBtn != null && !activeBtn.getStyleClass().contains("active")) {
            activeBtn.getStyleClass().add("active");
        }
    }

    private void clearActiveState(Button button) {
        if (button != null) {
            button.getStyleClass().remove("active");
        }
    }

    private void loadAnnouncements() {
        new Thread(() -> {
            try {
                String encodedDept = URLEncoder.encode(UserSession.getUserDept(), StandardCharsets.UTF_8.toString());
                String url = com.frontenddesktop.config.AppConfig.resolve("api/get_announcements.jsp?dept=") + encodedDept;
                String response = HttpConnector.get(url);

                if (response != null && response.trim().startsWith("[")) {
                    allAnnouncements = new Gson().fromJson(response, new TypeToken<List<Announcement>>(){}.getType());
                    Platform.runLater(() -> renderAnnouncements(allAnnouncements));
                }
            } catch (Exception e) {
                System.err.println("Announcement Load Error: " + e.getMessage());
            }
        }).start();
    }

    private void renderAnnouncements(List<Announcement> list) {
        announcementContainer.getChildren().clear();
        if (list.isEmpty()) {
            Label placeholder = new Label("No announcements for " + UserSession.getUserDept());
            placeholder.setStyle("-fx-text-fill: #95a5a6; -fx-padding: 10; -fx-font-style: italic;");
            announcementContainer.getChildren().add(placeholder);
            return;
        }

        for (Announcement a : list) {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/AnnouncementItem.fxml"));
                VBox card = loader.load();
                card.setMaxWidth(Double.MAX_VALUE);
                AnnouncementItemController controller = loader.getController();
                controller.setData(a, UserSession.getRole(), () -> Platform.runLater(this::loadAnnouncements));
                announcementContainer.getChildren().add(card);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void loadTaskList() {
        new Thread(() -> {
            try {
                String url = com.frontenddesktop.config.AppConfig.apiUrl("tasks.jsp");
                String response = HttpConnector.get(url);
                if (response != null) {
                    JsonElement json = JsonParser.parseString(response);
                    if (json.isJsonArray()) {
                        List<Task> allTasks = new Gson().fromJson(json, new TypeToken<List<Task>>(){}.getType());
                        List<Task> activeTasks = allTasks.stream()
                                .filter(t -> t.getAcknowledged() == 0)
                                .filter(t -> !"Archived".equalsIgnoreCase(t.getStatus()))
                                .collect(Collectors.toList());

                        Platform.runLater(() -> renderTasks(activeTasks));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    private void loadOverviewData() {
        new Thread(() -> {
            try {
                String taskResponse = HttpConnector.get(com.frontenddesktop.config.AppConfig.apiUrl("tasks.jsp"));
                int activeTaskCount = 0;
                if (taskResponse != null) {
                    JsonElement taskJson = JsonParser.parseString(taskResponse);
                    if (taskJson.isJsonArray()) {
                        List<Task> allTasks = new Gson().fromJson(taskJson, new TypeToken<List<Task>>(){}.getType());
                        activeTaskCount = (int) allTasks.stream()
                                .filter(t -> t.getAcknowledged() == 0)
                                .filter(t -> !"Archived".equalsIgnoreCase(t.getStatus()))
                                .count();
                    }
                }

                String encodedDept = URLEncoder.encode(UserSession.getUserDept(), StandardCharsets.UTF_8.toString());
                String announcementResponse = HttpConnector.get(com.frontenddesktop.config.AppConfig.resolve("api/get_announcements.jsp?dept=") + encodedDept);
                int announcementCount = 0;
                if (announcementResponse != null && announcementResponse.trim().startsWith("[")) {
                    List<Announcement> announcements = new Gson().fromJson(announcementResponse, new TypeToken<List<Announcement>>(){}.getType());
                    announcementCount = announcements != null ? announcements.size() : 0;
                }

                int finalActiveTaskCount = activeTaskCount;
                int finalAnnouncementCount = announcementCount;
                boolean isDeptHead = "Dept Head".equalsIgnoreCase(UserSession.getRole());
                Platform.runLater(() -> {
                    lblTaskCount.setText(String.valueOf(finalActiveTaskCount));
                    if (lblAnnouncementCount != null) {
                        lblAnnouncementCount.setText(String.valueOf(finalAnnouncementCount));
                    }
                    if (!isDeptHead && lblAnnouncementCardTitle != null) {
                        lblAnnouncementCardTitle.setText(finalAnnouncementCount > 0 ? "Department Updates" : "No Updates");
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    private void renderTasks(List<Task> list) {
        taskContainer.getChildren().clear();
        if (list.isEmpty()) {
            Label placeholder = new Label("No active tasks found.");
            placeholder.setStyle("-fx-text-fill: #95a5a6; -fx-padding: 20;");
            taskContainer.getChildren().add(placeholder);
            return;
        }

        for (Task t : list) {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/TaskItem.fxml"));
                HBox card = loader.load();
                card.setMaxWidth(Double.MAX_VALUE);
                VBox.setVgrow(card, Priority.NEVER);
                TaskItemController controller = loader.getController();
                controller.setData(t, () -> {
                    loadTaskList();
                    loadOverviewData();
                });
                taskContainer.getChildren().add(card);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @FXML
    private void loadTaskView() {
        currentSection = SectionView.OVERVIEW;
        setActiveButton(btnTasks);
        showPrimaryPane(overviewPane);
        loadOverviewData();
        Platform.runLater(() -> overviewPane.setVvalue(0));
    }

    @FXML
    private void loadTasksSection() {
        currentSection = SectionView.TASKS;
        setActiveButton(btnSidebarTasks);
        showPrimaryPane(taskOverviewPane);
        loadTaskList();
        Platform.runLater(() -> taskOverviewPane.setVvalue(0));
    }

    @FXML
    private void loadAnnouncementsSection() {
        currentSection = SectionView.ANNOUNCEMENTS;
        setActiveButton(btnSidebarAnnouncements);
        showPrimaryPane(announcementOverviewPane);
        loadAnnouncements();
        Platform.runLater(() -> announcementOverviewPane.setVvalue(0));
    }

    @FXML
    private void loadChatView() {
        currentSection = SectionView.CHAT;
        setActiveButton(btnChat);
        markMessagesAsRead();
        if (chatNotificationDot != null) {
            chatNotificationDot.setVisible(false);
        }
        switchView("/com/frontenddesktop/view/ChatView.fxml");
    }

    @FXML
    private void loadProfileView() {
        if (switchView("/com/frontenddesktop/view/ProfileView.fxml")) {
            currentSection = SectionView.PROFILE;
            setActiveButton(btnProfile);
            hidePrimaryPanes();
        } else {
            currentSection = SectionView.OVERVIEW;
            setActiveButton(btnTasks);
            showPrimaryPane(overviewPane);
        }
    }

    private void showPrimaryPane(ScrollPane paneToShow) {
        hidePrimaryPanes();
        if (paneToShow != null) {
            paneToShow.setManaged(true);
            paneToShow.setVisible(true);
        }
        if (contentArea != null && paneToShow != null) {
            contentArea.getChildren().setAll(paneToShow);
        }
    }

    private void hidePrimaryPanes() {
        setPaneHidden(overviewPane);
        setPaneHidden(taskOverviewPane);
        setPaneHidden(announcementOverviewPane);
    }

    private void setPaneHidden(ScrollPane pane) {
        if (pane != null) {
            pane.setVisible(false);
            pane.setManaged(false);
        }
    }

    private boolean switchView(String fxmlPath) {
        try {
            URL location = getClass().getResource(fxmlPath);
            if (location == null) return false;

            FXMLLoader loader = new FXMLLoader(location);
            Parent view = loader.load();
            if ("/com/frontenddesktop/view/ProfileView.fxml".equals(fxmlPath)) {
                ProfileController controller = loader.getController();
                if (controller != null) {
                    controller.setOnProfilePhotoUpdated(this::refreshUserIdentity);
                }
            }
            contentArea.getChildren().setAll(view);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.ERROR);
                alert.setTitle("View Error");
                alert.setHeaderText(null);
                alert.setContentText("Could not load this screen.");
                alert.showAndWait();
            });
            return false;
        }
    }

    @FXML
    private void openTaskCreator() {
        showModal("/com/frontenddesktop/view/TaskModal.fxml", "Assign New Task");
        loadOverviewData();
        if (currentSection == SectionView.TASKS) {
            loadTaskList();
        }
    }

    @FXML
    private void openAnnouncementCreator() {
        showModal("/com/frontenddesktop/view/PostAnnouncementModal.fxml", "New Announcement");
        loadOverviewData();
        if (currentSection == SectionView.ANNOUNCEMENTS) {
            loadAnnouncements();
        }
    }

    private void showModal(String fxml, String title) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(fxml));
            Parent root = loader.load();
            Stage stage = new Stage();
            stage.setTitle(title);
            stage.initModality(Modality.APPLICATION_MODAL);
            stage.setScene(new Scene(root));
            stage.showAndWait();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void refreshDashboard() {
        loadOverviewData();
    }

    private void startNotificationPolling() {
        notificationTimer = new Timer(true);
        notificationTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                try {
                    String url = com.frontenddesktop.config.AppConfig.resolve("api/check_unread.jsp?user_id=") + UserSession.getUserId();
                    String response = HttpConnector.get(url);
                    if (response != null && response.contains("\"unread\":true")) {
                        Platform.runLater(() -> {
                            if (chatNotificationDot != null) {
                                chatNotificationDot.setVisible(true);
                            }
                        });
                    }
                } catch (Exception ignored) {
                }
            }
        }, 0, 5000);
    }

    private void markMessagesAsRead() {
        new Thread(() -> {
            try {
                HttpConnector.get(com.frontenddesktop.config.AppConfig.resolve("api/mark_read.jsp?user_id=") + UserSession.getUserId());
            } catch (Exception ignored) {
            }
        }).start();
    }

    private void filterAnnouncements(String query) {
        List<Announcement> filtered = allAnnouncements.stream()
                .filter(a -> a.getTitle().toLowerCase().contains(query.toLowerCase()))
                .collect(Collectors.toList());
        renderAnnouncements(filtered);
    }

    @FXML
    private void handleLogout() {
        HttpConnector.clearSession();
        UserSession.clean();
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/Login.fxml"));
            Parent root = loader.load();
            Stage stage = (Stage) logoutBtn.getScene().getWindow();
            Scene scene = new Scene(root);
            stage.setScene(scene);
            stage.setTitle("University System - Login");
            stage.centerOnScreen();
            stage.show();
        } catch (IOException e) {
            e.printStackTrace();
            Alert alert = new Alert(Alert.AlertType.ERROR, "Error: Could not return to login screen.");
            alert.show();
        }
    }
}

