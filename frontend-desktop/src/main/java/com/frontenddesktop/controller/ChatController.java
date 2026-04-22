package com.frontenddesktop.controller;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.model.ChatUser;
import com.frontenddesktop.network.HttpConnector;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.Region;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.stage.FileChooser;
import javafx.stage.Modality;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

public class ChatController {
    @FXML private ListView<ChatUser> channelList;
    @FXML private TextField searchField;
    @FXML private Button btnClearSearch;
    @FXML private VBox chatBox;
    @FXML private ScrollPane chatScrollPane;
    @FXML private TextField messageField;
    @FXML private Label lblChatHeader;
    @FXML private Label lblDeptHeader;
    @FXML private HBox attachmentBar;
    @FXML private Label lblFileName;
    @FXML private Circle statusCircle;

    @FXML private HBox replyPreviewBar;
    @FXML private Label lblReplyText;

    private final ObservableList<ChatUser> masterData = FXCollections.observableArrayList();
    private Timer chatTimer;
    private int currentTargetId = -1;
    private File pendingFile = null;
    private Map<String, Object> replyingToMessage = null;
    private volatile boolean loadingMessages = false;
    private String lastMessagesPayload = null;
    private final String BASE_URL = com.frontenddesktop.config.AppConfig.getBackendBaseUrl() + "/";

    public void initialize() {
        Platform.runLater(() -> {
            try {
                String cssPath = "/com/frontenddesktop/styles/style.css";
                URL cssResource = getClass().getResource(cssPath);
                if (cssResource != null) {
                    chatBox.getScene().getStylesheets().add(cssResource.toExternalForm());
                }
            } catch (Exception e) {
                System.err.println("Style loading skipped: " + e.getMessage());
            }
        });

        FilteredList<ChatUser> filteredData = new FilteredList<>(masterData, p -> true);

        searchField.textProperty().addListener((observable, oldValue, newValue) -> {
            if (btnClearSearch != null) {
                btnClearSearch.setVisible(newValue != null && !newValue.isEmpty());
            }
            filteredData.setPredicate(user -> {
                if (newValue == null || newValue.isEmpty()) return true;
                return user.getName().toLowerCase().contains(newValue.toLowerCase());
            });
        });
        channelList.setItems(filteredData);

        channelList.setCellFactory(lv -> new ListCell<ChatUser>() {
            @Override
            protected void updateItem(ChatUser user, boolean empty) {
                super.updateItem(user, empty);
                if (empty || user == null) {
                    setGraphic(null);
                    setText(null);
                } else {
                    HBox container = new HBox(10);
                    container.setAlignment(Pos.CENTER_LEFT);
                    Circle statusDot = new Circle(5, user.isOnline() ? Color.web("#2ecc71") : Color.GRAY);

                    VBox labelBox = new VBox(2);
                    Label nameLabel = new Label(user.getName());
                    nameLabel.setStyle("-fx-font-weight: bold; -fx-text-fill: #2c3e50;");
                    Label previewLabel = new Label(user.getLastMessage());
                    previewLabel.setStyle("-fx-font-size: 11px; -fx-text-fill: #7f8c8d;");
                    previewLabel.setMaxWidth(140);
                    labelBox.getChildren().addAll(nameLabel, previewLabel);

                    container.getChildren().addAll(statusDot, labelBox);

                    if (user.getUnreadCount() > 0) {
                        Region spacer = new Region();
                        HBox.setHgrow(spacer, Priority.ALWAYS);
                        Label badge = new Label(String.valueOf(user.getUnreadCount()));
                        badge.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-background-radius: 10; -fx-padding: 2 6 2 6; -fx-font-size: 10px;");
                        container.getChildren().addAll(spacer, badge);
                    }
                    setGraphic(container);
                }
            }
        });

        channelList.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal != null) {
                this.currentTargetId = newVal.getId();
                this.lastMessagesPayload = null;
                this.lblChatHeader.setText(newVal.getName());
                cancelReply();

                if (newVal.getId() == 0) {
                    lblDeptHeader.setText("Unit: " + newVal.getDepartment());
                } else {
                    lblDeptHeader.setText("Department: " + newVal.getDepartment());
                    markMessagesAsRead(newVal.getId());
                    newVal.setUnreadCount(0);
                    channelList.refresh();
                }
                loadMessages();
            }
        });

        fetchUserList();
        startChatPolling();

        chatBox.heightProperty().addListener((obs, oldVal, newVal) ->
                chatScrollPane.setVvalue(1.0));
    }

    private void checkServerConnection() {
        new Thread(() -> {
            boolean isOnline = false;
            try {
                URL url = new URL(BASE_URL + "api/get_users.jsp");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setConnectTimeout(2000);
                conn.setRequestMethod("HEAD");
                isOnline = (conn.getResponseCode() == HttpURLConnection.HTTP_OK);
            } catch (Exception e) { isOnline = false; }

            final boolean finalStatus = isOnline;
            Platform.runLater(() -> {
                if (statusCircle != null) {
                    statusCircle.setFill(finalStatus ? Color.web("#2ecc71") : Color.web("#e74c3c"));
                    Tooltip.install(statusCircle, new Tooltip(finalStatus ? "Server Online" : "Server Offline"));
                }
            });
        }).start();
    }

    private void setupReply(Map<String, Object> msg) {
        this.replyingToMessage = msg;
        String preview = (String) msg.get("message");
        String path = (String) msg.get("attachment_path");

        if ((preview == null || preview.trim().isEmpty()) && path != null) {
            boolean isImg = path.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$");
            preview = isImg ? "📷 Image" : "📁 File";
        } else if (preview == null) {
            preview = "...";
        }

        if (preview.length() > 40) preview = preview.substring(0, 37) + "...";

        lblReplyText.setText("Replying to: " + preview);
        replyPreviewBar.setVisible(true);
        replyPreviewBar.setManaged(true);
        messageField.requestFocus();
    }

    private void jumpToMessage(int targetId) {
        for (javafx.scene.Node node : chatBox.getChildren()) {
            if (node instanceof VBox && node.getUserData() != null) {
                int currentId = (int) node.getUserData();

                if (currentId == targetId) {
                    double vBoxHeight = chatBox.getHeight();
                    double nodeY = node.getBoundsInParent().getMinY();
                    chatScrollPane.setVvalue(nodeY / vBoxHeight);
                    node.setStyle("-fx-border-color: #3498db; -fx-border-width: 0 0 0 4; -fx-border-radius: 2;");
                    new Thread(() -> {
                        try {
                            Thread.sleep(1000);
                            Platform.runLater(() -> node.setStyle("-fx-border-width: 0;"));
                        } catch (InterruptedException ex) { }
                    }).start();
                    break;
                }
            }
        }
    }

    @FXML
    private void cancelReply() {
        this.replyingToMessage = null;
        if (replyPreviewBar != null) {
            replyPreviewBar.setVisible(false);
            replyPreviewBar.setManaged(false);
        }
    }

    private void handleDeleteAction(int chatId) {
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION, "Delete this message?", ButtonType.YES, ButtonType.NO);
        confirm.showAndWait().ifPresent(response -> {
            if (response == ButtonType.YES) {
                new Thread(() -> {
                    try {
                        Map<String, String> params = new HashMap<>();
                        params.put("action", "delete");
                        params.put("chat_id", String.valueOf(chatId));
                        HttpConnector.post(BASE_URL + "api/edit_delete_message.jsp", params);
                        Platform.runLater(this::loadMessages);
                    } catch (Exception e) { e.printStackTrace(); }
                }).start();
            }
        });
    }

    private void handleEditAction(int chatId, String oldText) {
        TextInputDialog dialog = new TextInputDialog(oldText);
        dialog.setTitle("Edit Message");
        dialog.setHeaderText("Modify your message:");

        dialog.showAndWait().ifPresent(newText -> {
            if (!newText.trim().isEmpty() && !newText.equals(oldText)) {
                new Thread(() -> {
                    try {
                        Map<String, String> params = new HashMap<>();
                        params.put("action", "edit");
                        params.put("chat_id", String.valueOf(chatId));
                        params.put("message", newText);
                        HttpConnector.post(BASE_URL + "api/edit_delete_message.jsp", params);
                        Platform.runLater(this::loadMessages);
                    } catch (Exception e) {
                        e.printStackTrace();
                        Platform.runLater(() -> {
                            new Alert(Alert.AlertType.ERROR, "Failed to connect to server for edit.").show();
                        });
                    }
                }).start();
            }
        });
    }

    private void handleDeleteFile(int chatId) {
        new Thread(() -> {
            try {
                Map<String, String> params = new HashMap<>();
                params.put("action", "delete_file");
                params.put("chat_id", String.valueOf(chatId));
                HttpConnector.post(BASE_URL + "api/edit_delete_message.jsp", params);
                Platform.runLater(this::loadMessages);
            } catch (Exception e) { e.printStackTrace(); }
        }).start();
    }

    private void handleReplaceFile(int chatId) {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Select New Attachment");
        File selected = fileChooser.showOpenDialog(chatBox.getScene().getWindow());

        if (selected != null) {
            new Thread(() -> {
                try {
                    Map<String, String> params = new HashMap<>();
                    params.put("chat_id", String.valueOf(chatId));
                    // The backend send_message.jsp should handle "update" if chat_id is present
                    String response = HttpConnector.postMultipart(BASE_URL + "api/send_message.jsp", params, selected);
                    Platform.runLater(() -> {
                        if (response != null && response.contains("\"status\":\"success\"")) {
                            lastMessagesPayload = null;
                            loadMessages();
                        } else {
                            new Alert(Alert.AlertType.ERROR, "Attachment replacement failed.").show();
                        }
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                    Platform.runLater(() -> new Alert(Alert.AlertType.ERROR, "Failed to replace file.").show());
                }
            }).start();
        }
    }
    private void markMessagesAsRead(int targetId) {
        new Thread(() -> {
            try {
                String url = BASE_URL + "api/mark_as_read.jsp?target_id=" + targetId;
                HttpConnector.get(url);
            } catch (Exception e) { e.printStackTrace(); }
        }).start();
    }

    @FXML
    private void handleClearSearch() {
        if (searchField != null) {
            searchField.clear();
            searchField.requestFocus();
        }
    }

    private void fetchUserList() {
        new Thread(() -> {
            try {
                String url = BASE_URL + "api/get_users.jsp";
                String response = HttpConnector.get(url);

                if (response != null && response.startsWith("[")) {
                    List<Map<String, Object>> users = new Gson().fromJson(response,
                            new TypeToken<List<Map<String, Object>>>(){}.getType());

                    Platform.runLater(() -> {
                        String userDept = "General";
                        for (Map<String, Object> u : users) {
                            if (!"admin".equalsIgnoreCase((String) u.get("role"))) {
                                userDept = (String) u.getOrDefault("department", "General");
                                break;
                            }
                        }

                        masterData.clear();
                        masterData.add(new ChatUser(0, userDept + " Dept", "Group messaging", true, userDept, 0));

                        for (Map<String, Object> u : users) {
                            try {
                                int id = ((Double) u.get("user_id")).intValue();
                                String name = (String) u.get("full_name");
                                String lastMsg = (String) u.getOrDefault("last_msg", "No messages yet");
                                String dept = (String) u.getOrDefault("department", "N/A");
                                boolean online = u.get("is_online") != null && (boolean) u.get("is_online");
                                int unread = u.get("unread_count") != null ? ((Double) u.get("unread_count")).intValue() : 0;

                                masterData.add(new ChatUser(id, name, lastMsg, online, dept, unread));
                            } catch (Exception e) {
                                System.err.println("Error parsing user: " + e.getMessage());
                            }
                        }
                    });
                }
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> {
                    if (statusCircle != null) statusCircle.setFill(Color.RED);
                });
            }
        }).start();
    }

    private void startChatPolling() {
        chatTimer = new Timer(true);
        chatTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                loadMessages();
                checkServerConnection();
            }
        }, 0, 3000);
    }

    private void loadMessages() {
        if (currentTargetId == -1 || loadingMessages) return;
        loadingMessages = true;
        try {
            String url = BASE_URL + "api/get_messages.jsp?target_id=" + currentTargetId;
            String response = HttpConnector.get(url);
            if (response != null && response.startsWith("[")) {
                if (response.equals(lastMessagesPayload)) {
                    return;
                }
                lastMessagesPayload = response;
                List<Map<String, Object>> messages = new Gson().fromJson(response, new TypeToken<List<Map<String, Object>>>(){}.getType());
                Platform.runLater(() -> {
                    chatBox.getChildren().clear();
                    for (Map<String, Object> msg : messages) renderBubble(msg);
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            loadingMessages = false;
        }
    }
    private void renderBubble(Map<String, Object> msg) {
        int chatId = ((Double) msg.get("chat_id")).intValue();
        String content = (String) msg.get("message");
        String relativePath = (String) msg.get("attachment_path");
        String timestamp = (String) msg.get("sent_at");

        String senderName = (String) msg.getOrDefault("sender_name", "Staff");
        int receiverId = ((Double) msg.get("receiver_id")).intValue();
        int senderId = ((Double) msg.get("sender_id")).intValue();
        boolean isMine = (senderId == UserSession.getUserId());

        VBox container = new VBox(3);
        container.setAlignment(isMine ? Pos.CENTER_RIGHT : Pos.CENTER_LEFT);
        container.setUserData(chatId);

        if (!isMine && receiverId == 0) {
            HBox header = new HBox(8);
            header.setAlignment(Pos.BASELINE_LEFT);
            Label lblName = new Label(senderName);
            lblName.getStyleClass().add("group-sender-name");
            String timeStr = (timestamp != null && timestamp.length() > 16) ? timestamp.substring(11, 16) : "";
            Label lblTimeHeader = new Label(timeStr);
            lblTimeHeader.getStyleClass().add("group-timestamp");
            header.getChildren().addAll(lblName, lblTimeHeader);
            container.getChildren().add(header);
        }

        if (msg.get("reply_to_text") != null && msg.get("reply_to_id") != null) {
            int originalId = ((Double) msg.get("reply_to_id")).intValue();
            Hyperlink hlReply = new Hyperlink("⤴ " + msg.get("reply_to_text"));
            hlReply.getStyleClass().add("reply-reference");
            hlReply.setUnderline(false);
            hlReply.setOnAction(e -> jumpToMessage(originalId));
            container.getChildren().add(hlReply);
        }

        if (content != null && !content.isEmpty()) {
            Label lblMsg = new Label(content);
            lblMsg.setWrapText(true);
            lblMsg.setMaxWidth(400);
            lblMsg.getStyleClass().add(isMine ? "sent-bubble" : "received-bubble");
            lblMsg.setOnMouseClicked(e -> { if (e.getClickCount() == 2) setupReply(msg); });

            ContextMenu contextMenu = new ContextMenu();
            MenuItem replyItem = new MenuItem("Reply");
            replyItem.setOnAction(e -> setupReply(msg));
            contextMenu.getItems().add(replyItem);

            if (isMine) {
                MenuItem editItem = new MenuItem("Edit Message");
                MenuItem deleteItem = new MenuItem("Delete Message");
                editItem.setOnAction(e -> handleEditAction(chatId, content));
                deleteItem.setOnAction(e -> handleDeleteAction(chatId));
                contextMenu.getItems().addAll(new SeparatorMenuItem(), editItem, deleteItem);
            }
            lblMsg.setContextMenu(contextMenu);
            container.getChildren().add(lblMsg);
        }

        if (relativePath != null && !relativePath.isEmpty()) {
            String fileName = relativePath.substring(relativePath.lastIndexOf("/") + 1);
            String cleanPath = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;
            String fullUrl = BASE_URL + cleanPath;

            boolean isImg = relativePath.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$");

            if (isImg) {
                ImageView imgView = new ImageView(new Image(fullUrl, 250, 250, true, true, true));
                imgView.setCursor(javafx.scene.Cursor.HAND);
                imgView.getStyleClass().add("chat-img-preview");

                // Left-Click: Full Screen Preview
                imgView.setOnMouseClicked(e -> {
                    if (e.getButton() == javafx.scene.input.MouseButton.PRIMARY) {
                        if (e.getClickCount() == 1) {
                            showFullScreenImage(fullUrl);
                        } else if (e.getClickCount() == 2) {
                            setupReply(msg);
                        }
                    }
                });

                ContextMenu imgMenu = new ContextMenu();
                MenuItem replyImg = new MenuItem("Reply to Image");
                replyImg.setOnAction(ev -> setupReply(msg));
                imgMenu.getItems().add(replyImg);

                if (isMine) {
                    MenuItem replaceImg = new MenuItem("Replace Image");
                    replaceImg.setOnAction(ev -> handleReplaceFile(chatId));
                    MenuItem editImgMsg = new MenuItem("Edit Message");
                    editImgMsg.setOnAction(ev -> handleEditAction(chatId, content));
                    MenuItem delImg = new MenuItem("Delete Image");
                    delImg.setOnAction(ev -> handleDeleteAction(chatId));
                    imgMenu.getItems().addAll(new SeparatorMenuItem(), replaceImg, editImgMsg, delImg);
                }

                // Right-Click: Management Menu Only (e.consume() prevents click bubbling)
                imgView.setOnContextMenuRequested(e -> {
                    imgMenu.show(imgView, e.getScreenX(), e.getScreenY());
                    e.consume();
                });

                container.getChildren().add(imgView);
            } else {
                Hyperlink link = new Hyperlink("📁 " + fileName);
                link.setStyle("-fx-font-size: 11px; -fx-text-fill: #2980b9;");

                // Left-Click: Standard Preview/Action
                link.setOnAction(e -> previewFile(fullUrl, fileName));

                ContextMenu fileMenu = new ContextMenu();
                MenuItem replyFileItem = new MenuItem("Reply to File");
                replyFileItem.setOnAction(e -> setupReply(msg));
                MenuItem downloadItem = new MenuItem("Save As...");
                downloadItem.setOnAction(e -> downloadFile(fullUrl, fileName));
                fileMenu.getItems().addAll(replyFileItem, new SeparatorMenuItem(), downloadItem);

                if (isMine) {
                    MenuItem replaceFile = new MenuItem("Replace Attachment");
                    replaceFile.setOnAction(e -> handleReplaceFile(chatId));
                    MenuItem deleteFile = new MenuItem("Remove Attachment");
                    deleteFile.setOnAction(e -> handleDeleteFile(chatId));
                    fileMenu.getItems().addAll(new SeparatorMenuItem(), replaceFile, deleteFile);
                }
                link.setContextMenu(fileMenu);
                container.getChildren().add(link);
            }
        }

        if (timestamp != null && (isMine || receiverId != 0)) {
            String timeStr = timestamp.length() > 16 ? timestamp.substring(11, 16) : timestamp;
            Label lblTime = new Label(timeStr);
            lblTime.getStyleClass().add("footer-timestamp");
            HBox timeWrapper = new HBox(lblTime);
            timeWrapper.setAlignment(isMine ? Pos.CENTER_RIGHT : Pos.CENTER_LEFT);
            container.getChildren().add(timeWrapper);
        }

        chatBox.getChildren().add(container);
    }
    // Add these as local variables inside the method or fields in the class
    private double mouseAnchorX;
    private double mouseAnchorY;

    private void showFullScreenImage(String imageUrl) {
        Stage stage = new Stage();
        stage.initModality(Modality.APPLICATION_MODAL);
        stage.initStyle(StageStyle.TRANSPARENT);
        stage.setTitle("Image Preview");

        ImageView fullImageView = new ImageView(new Image(imageUrl));
        fullImageView.setPreserveRatio(true);

        // Wrap ImageView in a Group to allow scaling and translation
        javafx.scene.Group zoomGroup = new javafx.scene.Group(fullImageView);

        // --- Download Button (Top Right) ---
        Button btnDownload = new Button("Download");
        btnDownload.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-weight: bold; -fx-cursor: hand; -fx-padding: 8 15; -fx-background-radius: 5;");
        String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
        btnDownload.setOnAction(e -> downloadFile(imageUrl, fileName));

        // --- Exit Button (Top Left) ---
        Button btnExit = new Button("✕ Close");
        btnExit.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-font-weight: bold; -fx-cursor: hand; -fx-padding: 8 15; -fx-background-radius: 5;");
        btnExit.setOnAction(e -> stage.close());

        // Layout Container
        StackPane root = new StackPane(zoomGroup);
        root.setStyle("-fx-background-color: rgba(0, 0, 0, 0.95);");

        HBox controls = new HBox();
        controls.setAlignment(Pos.TOP_CENTER);
        controls.setPadding(new javafx.geometry.Insets(25));
        controls.setPickOnBounds(false);

        Region spacer = new Region();
        HBox.setHgrow(spacer, Priority.ALWAYS);

        controls.getChildren().addAll(btnExit, spacer, btnDownload);
        root.getChildren().add(controls);

        Scene scene = new Scene(root);
        scene.setFill(Color.TRANSPARENT);

        // --- Zoom Logic ---
        root.setOnScroll(event -> {
            double zoomFactor = (event.getDeltaY() < 0) ? 0.95 : 1.05;
            double newScaleX = zoomGroup.getScaleX() * zoomFactor;
            double newScaleY = zoomGroup.getScaleY() * zoomFactor;

            if (newScaleX >= 0.5 && newScaleX <= 5.0) {
                zoomGroup.setScaleX(newScaleX);
                zoomGroup.setScaleY(newScaleY);
            }
            event.consume();
        });

        // --- Click-and-Drag Logic ---
        zoomGroup.setOnMousePressed(event -> {
            mouseAnchorX = event.getSceneX() - zoomGroup.getTranslateX();
            mouseAnchorY = event.getSceneY() - zoomGroup.getTranslateY();
            zoomGroup.setCursor(javafx.scene.Cursor.CLOSED_HAND);
        });

        zoomGroup.setOnMouseDragged(event -> {
            zoomGroup.setTranslateX(event.getSceneX() - mouseAnchorX);
            zoomGroup.setTranslateY(event.getSceneY() - mouseAnchorY);
        });

        zoomGroup.setOnMouseReleased(event -> {
            zoomGroup.setCursor(javafx.scene.Cursor.HAND);
        });

        // --- Keyboard Listener (ESC to Close) ---
        scene.setOnKeyPressed(event -> {
            if (event.getCode() == javafx.scene.input.KeyCode.ESCAPE) stage.close();
        });

        fullImageView.fitWidthProperty().bind(scene.widthProperty().multiply(0.8));
        fullImageView.fitHeightProperty().bind(scene.heightProperty().multiply(0.8));

        // Close on clicking the dark background area
        root.setOnMouseClicked(e -> {
            if (e.getTarget() == root) stage.close();
        });

        stage.setScene(scene);
        stage.setMaximized(true);
        stage.show();
    }
    private void previewFile(String fileUrl, String fileName) {
        new Thread(() -> {
            try {
                URL url = new URL(fileUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    Platform.runLater(() -> new Alert(Alert.AlertType.ERROR, "File not available on server.").show());
                    return;
                }

                File tempFile = File.createTempFile("preview_", "_" + fileName);
                tempFile.deleteOnExit();

                try (InputStream in = conn.getInputStream();
                     FileOutputStream out = new FileOutputStream(tempFile)) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                }

                if (java.awt.Desktop.isDesktopSupported()) {
                    java.awt.Desktop.getDesktop().open(tempFile);
                } else {
                    Platform.runLater(() -> new Alert(Alert.AlertType.WARNING, "System preview not supported.").show());
                }
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> new Alert(Alert.AlertType.ERROR, "Could not open file: " + e.getMessage()).show());
            }
        }).start();
    }

    @FXML
    private void handleSendMessage() {
        if (currentTargetId == -1) return;
        String text = messageField.getText().trim();
        if (text.isEmpty() && pendingFile == null) return;

        final String msgContent = text;
        final File fileToUpload = pendingFile;
        final Map<String, Object> replyTarget = replyingToMessage;

        messageField.clear();
        messageField.setDisable(true);
        cancelReply();

        executeSendTask(msgContent, fileToUpload, replyTarget);
    }

    private void executeSendTask(String msgContent, File fileToUpload, Map<String, Object> replyTarget) {
        new Thread(() -> {
            try {
                Map<String, String> params = new HashMap<>();
                params.put("receiver_id", (currentTargetId <= 0) ? "0" : String.valueOf(currentTargetId));
                params.put("message", msgContent);

                if (replyTarget != null) {
                    int replyId = ((Double) replyTarget.get("chat_id")).intValue();
                    params.put("reply_to_id", String.valueOf(replyId));
                }

                String response = HttpConnector.postMultipart(BASE_URL + "api/send_message.jsp", params, fileToUpload);
                Platform.runLater(() -> {
                    messageField.setDisable(false);
                    if (response != null && response.contains("success")) {
                        lastMessagesPayload = null;
                        handleClearAttachment();
                        loadMessages();
                    } else {
                        showRetryAlert("Server Error", "Message could not be saved.", msgContent, fileToUpload, replyTarget);
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> {
                    messageField.setDisable(false);
                    showRetryAlert("Connection Error", "Check your network or Tomcat status.", msgContent, fileToUpload, replyTarget);
                });
            }
        }).start();
    }

    private void showRetryAlert(String title, String content, String msg, File file, Map<String, Object> reply) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(content);

        ButtonType retryBtn = new ButtonType("Retry");
        ButtonType cancelBtn = new ButtonType("Cancel", ButtonBar.ButtonData.CANCEL_CLOSE);
        alert.getButtonTypes().setAll(retryBtn, cancelBtn);

        alert.showAndWait().ifPresent(type -> {
            if (type == retryBtn) {
                messageField.setDisable(true);
                executeSendTask(msg, file, reply);
            } else {
                messageField.setText(msg);
                if (reply != null) setupReply(reply);
            }
        });
    }

    @FXML
    private void handleAttachFile() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Attach File");
        fileChooser.getExtensionFilters().add(
                new FileChooser.ExtensionFilter(
                        "Supported Files",
                        "*.pdf", "*.doc", "*.docx", "*.xls", "*.xlsx", "*.ppt", "*.pptx",
                        "*.txt", "*.zip", "*.rar", "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp"
                )
        );
        File selected = fileChooser.showOpenDialog(messageField.getScene().getWindow());
        if (selected != null) {
            this.pendingFile = selected;
            lblFileName.setText(selected.getName());
            attachmentBar.setVisible(true);
            attachmentBar.setManaged(true);
        }
    }

    @FXML
    private void handleClearAttachment() {
        this.pendingFile = null;
        lblFileName.setText("");
        attachmentBar.setVisible(false);
        attachmentBar.setManaged(false);
    }

    private void downloadFile(String fileUrl, String fileName) {
        FileChooser saveChooser = new FileChooser();
        saveChooser.setInitialFileName(fileName);
        File dest = saveChooser.showSaveDialog(messageField.getScene().getWindow());
        if (dest == null) return;

        Dialog<Void> progressDialog = new Dialog<>();
        progressDialog.setTitle("File Transfer");
        progressDialog.setHeaderText("Downloading: " + fileName);
        ProgressBar pb = new ProgressBar(0);
        pb.setPrefWidth(300);
        Label lblStatus = new Label("Connecting...");
        progressDialog.getDialogPane().setContent(new VBox(10, pb, lblStatus));
        progressDialog.getDialogPane().getButtonTypes().add(ButtonType.CANCEL);

        Task<Void> task = new Task<>() {
            @Override protected Void call() throws Exception {
                HttpURLConnection conn = (HttpURLConnection) new URL(fileUrl).openConnection();
                if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    throw new IOException("Server returned HTTP " + conn.getResponseCode());
                }
                long totalSize = conn.getContentLengthLong();
                try (BufferedInputStream in = new BufferedInputStream(conn.getInputStream());
                     FileOutputStream out = new FileOutputStream(dest)) {
                    byte[] data = new byte[4096];
                    int n; long totalRead = 0;
                    while ((n = in.read(data)) != -1) {
                        if (isCancelled()) break;
                        out.write(data, 0, n);
                        totalRead += n;
                        updateProgress(totalRead, totalSize);
                        long current = totalRead;
                        Platform.runLater(() -> lblStatus.setText((current/1024) + " KB / " + (totalSize/1024) + " KB"));
                    }
                }
                return null;
            }
        };

        pb.progressProperty().bind(task.progressProperty());
        task.setOnSucceeded(e -> { progressDialog.close(); new Alert(Alert.AlertType.INFORMATION, "Download Complete").show(); });
        task.setOnFailed(e -> {
            progressDialog.close();
            new Alert(Alert.AlertType.ERROR, "Download Failed").show();
        });
        progressDialog.setOnCloseRequest(e -> task.cancel());
        new Thread(task).start();
        progressDialog.show();
    }

    public void stopPolling() { if (chatTimer != null) chatTimer.cancel(); }
}

