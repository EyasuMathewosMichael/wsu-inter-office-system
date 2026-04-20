package com.frontenddesktop.controller;

import com.frontenddesktop.model.UserSession;
import com.frontenddesktop.network.HttpConnector;
import com.frontenddesktop.util.ProfileImageUtil;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.shape.Circle;
import javafx.scene.text.Text;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import org.json.JSONObject;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class ProfileController {
    @FXML private Label lblFullName;
    @FXML private Label lblUserRole;
    @FXML private Label txtDeptDisplay;
    @FXML private Label lblPhotoStatus;
    @FXML private Text txtAvatarInitials;
    @FXML private ImageView imgProfileAvatar;
    @FXML private TextField txtId;
    @FXML private TextField txtDept;
    @FXML private TextField txtEmail;
    @FXML private TextField txtPhone;
    @FXML private TextArea txtBio;
    @FXML private PasswordField fieldCurrentPass;
    @FXML private PasswordField fieldNewPass;
    @FXML private PasswordField fieldConfirmPass;
    @FXML private Button btnUpdate;
    @FXML private Button btnSaveProfile;
    @FXML private Button btnChoosePhoto;
    @FXML private Button btnUploadPhoto;

    private File selectedPhotoFile;
    private Runnable onProfilePhotoUpdated;

    @FXML
    public void initialize() {
        lblFullName.setText(UserSession.getFullName());
        lblUserRole.setText(UserSession.getRole().toUpperCase());
        txtDeptDisplay.setText(UserSession.getUserDept());
        txtDept.setText(UserSession.getUserDept());
        txtId.setText("EMP-" + UserSession.getUserId());
        txtEmail.setText(UserSession.getPersonalEmail() != null ? UserSession.getPersonalEmail() : "");
        txtPhone.setText(UserSession.getPhone() != null ? UserSession.getPhone() : "");
        txtBio.setText(UserSession.getBio() != null ? UserSession.getBio() : "");
        renderProfileAvatar(UserSession.getProfilePhotoPath(), null);
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

    private void renderProfileAvatar(String storedPhotoPath, String previewUri) {
        txtAvatarInitials.setText(generateInitials(UserSession.getFullName()));
        txtAvatarInitials.setVisible(true);

        imgProfileAvatar.setVisible(false);
        imgProfileAvatar.setClip(new Circle(55, 55, 55));

        if (previewUri != null && !previewUri.isBlank()) {
            imgProfileAvatar.setImage(new Image(previewUri, 110, 110, false, true, true));
            imgProfileAvatar.setVisible(true);
            txtAvatarInitials.setVisible(false);
            return;
        }

        String imageUrl = ProfileImageUtil.buildProfileImageUrl(storedPhotoPath);
        if (imageUrl == null) {
            lblPhotoStatus.setText("No uploaded photo yet. Your initials are being used.");
            return;
        }

        Image image = new Image(imageUrl, 110, 110, false, true, true);
        image.errorProperty().addListener((obs, wasError, isError) -> {
            if (Boolean.TRUE.equals(isError)) {
                Platform.runLater(() -> {
                    imgProfileAvatar.setVisible(false);
                    txtAvatarInitials.setVisible(true);
                    lblPhotoStatus.setText("Saved photo could not be loaded. Your initials are being used.");
                });
            }
        });
        image.progressProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue.doubleValue() >= 1.0 && !image.isError()) {
                showProfileImage(image);
            }
        });
        imgProfileAvatar.setImage(image);
        if (image.getProgress() >= 1.0 && !image.isError()) {
            showProfileImage(image);
        }
    }

    private void showProfileImage(Image image) {
        Platform.runLater(() -> {
            imgProfileAvatar.setImage(image);
            imgProfileAvatar.setVisible(true);
            txtAvatarInitials.setVisible(false);
            lblPhotoStatus.setText("Your current profile photo will appear across the desktop app.");
        });
    }

    @FXML
    private void handleChoosePhoto() {
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Choose Profile Photo");
        chooser.getExtensionFilters().add(
                new FileChooser.ExtensionFilter("Image Files", "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp")
        );

        Stage stage = (Stage) lblFullName.getScene().getWindow();
        File chosenFile = chooser.showOpenDialog(stage);
        if (chosenFile == null) {
            return;
        }

        selectedPhotoFile = chosenFile;
        btnUploadPhoto.setDisable(false);
        lblPhotoStatus.setText("Selected: " + chosenFile.getName());
        renderProfileAvatar(null, chosenFile.toURI().toString());
    }

    @FXML
    private void handleSaveProfile() {
        String personalEmail = txtEmail.getText() != null ? txtEmail.getText().trim().toLowerCase() : "";
        String phone = txtPhone.getText() != null ? txtPhone.getText().trim() : "";
        String bio = txtBio.getText() != null ? txtBio.getText().trim() : "";

        if (!personalEmail.isEmpty() && !personalEmail.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            showAlert(Alert.AlertType.ERROR, "Validation Error", "Enter a valid personal email address.");
            return;
        }

        if (phone.length() > 30) {
            showAlert(Alert.AlertType.ERROR, "Validation Error", "Phone number must be 30 characters or fewer.");
            return;
        }

        if (bio.length() > 1000) {
            showAlert(Alert.AlertType.ERROR, "Validation Error", "Bio must be 1000 characters or fewer.");
            return;
        }

        btnSaveProfile.setDisable(true);
        btnSaveProfile.setText("Saving...");

        new Thread(() -> {
            try {
                Map<String, String> params = new HashMap<>();
                params.put("personal_email", personalEmail);
                params.put("phone", phone);
                params.put("bio", bio);
                String response = HttpConnector.post("http://localhost:8080/backend-web/api/update_user_profile.jsp", params);

                Platform.runLater(() -> {
                    btnSaveProfile.setDisable(false);
                    btnSaveProfile.setText("Save Profile Details");

                    if (response != null && response.trim().startsWith("{")) {
                        JSONObject result = new JSONObject(response);
                        if (result.optBoolean("success", false)) {
                            UserSession.setPersonalEmail(result.optString("personal_email", personalEmail));
                            UserSession.setPhone(result.optString("phone", phone));
                            UserSession.setBio(result.optString("bio", bio));
                            txtEmail.setText(UserSession.getPersonalEmail() != null ? UserSession.getPersonalEmail() : "");
                            txtPhone.setText(UserSession.getPhone() != null ? UserSession.getPhone() : "");
                            txtBio.setText(UserSession.getBio() != null ? UserSession.getBio() : "");
                            showAlert(Alert.AlertType.INFORMATION, "Success", result.optString("message", "Profile details updated."));
                        } else {
                            showAlert(Alert.AlertType.ERROR, "Update Failed", result.optString("message", "Could not update profile details."));
                        }
                    } else {
                        showAlert(Alert.AlertType.ERROR, "Update Failed", "The server returned an invalid response.");
                    }
                });
            } catch (Exception e) {
                Platform.runLater(() -> {
                    btnSaveProfile.setDisable(false);
                    btnSaveProfile.setText("Save Profile Details");
                    showAlert(Alert.AlertType.ERROR, "Connection Error", "Could not reach the server.");
                });
            }
        }).start();
    }

    @FXML
    private void handleUploadPhoto() {
        if (selectedPhotoFile == null) {
            showAlert(Alert.AlertType.WARNING, "No Photo Selected", "Choose an image before uploading.");
            return;
        }

        btnChoosePhoto.setDisable(true);
        btnUploadPhoto.setDisable(true);
        btnUploadPhoto.setText("Uploading...");
        lblPhotoStatus.setText("Uploading profile photo...");

        new Thread(() -> {
            try {
                String response = HttpConnector.postMultipart(
                        "http://localhost:8080/backend-web/api/update_user_profile_photo.jsp",
                        new HashMap<>(),
                        selectedPhotoFile,
                        "profile_pic"
                );

                Platform.runLater(() -> {
                    btnChoosePhoto.setDisable(false);
                    btnUploadPhoto.setText("Upload Photo");

                    if (response == null || !response.trim().startsWith("{")) {
                        btnUploadPhoto.setDisable(false);
                        lblPhotoStatus.setText("Upload failed. Please try again.");
                        showAlert(Alert.AlertType.ERROR, "Upload Failed", "The server returned an invalid response.");
                        return;
                    }

                    JSONObject result = new JSONObject(response);
                    if (result.optBoolean("success", false)) {
                        String newPhotoPath = result.optString("profile_pic_path", null);
                        UserSession.setProfilePhotoPath(newPhotoPath);
                        selectedPhotoFile = null;
                        btnUploadPhoto.setDisable(true);
                        lblPhotoStatus.setText(result.optString("message", "Profile photo updated successfully."));
                        renderProfileAvatar(newPhotoPath, null);
                        if (onProfilePhotoUpdated != null) {
                            onProfilePhotoUpdated.run();
                        }
                        showAlert(Alert.AlertType.INFORMATION, "Success", "Profile photo updated.");
                    } else {
                        btnUploadPhoto.setDisable(false);
                        lblPhotoStatus.setText(result.optString("message", "Profile photo update failed."));
                        showAlert(Alert.AlertType.ERROR, "Upload Failed", result.optString("message", "Upload failed."));
                    }
                });
            } catch (Exception e) {
                Platform.runLater(() -> {
                    btnChoosePhoto.setDisable(false);
                    btnUploadPhoto.setDisable(false);
                    btnUploadPhoto.setText("Upload Photo");
                    lblPhotoStatus.setText("Could not reach the server.");
                    showAlert(Alert.AlertType.ERROR, "Connection Error", "Could not reach the server.");
                });
            }
        }).start();
    }

    @FXML
    private void handleUpdatePassword() {
        String currentPass = fieldCurrentPass.getText();
        String newPass = fieldNewPass.getText();
        String confirmPass = fieldConfirmPass.getText();

        if (currentPass.isEmpty() || newPass.isEmpty() || confirmPass.isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Validation", "Please fill all fields.");
            return;
        }

        if (!newPass.equals(confirmPass)) {
            showAlert(Alert.AlertType.ERROR, "Mismatch", "New passwords do not match.");
            return;
        }

        btnUpdate.setDisable(true);
        btnUpdate.setText("Updating...");

        new Thread(() -> {
            try {
                Map<String, String> params = new HashMap<>();
                params.put("old_pass", currentPass);
                params.put("new_pass", newPass);
                String response = HttpConnector.post("http://localhost:8080/backend-web/api/update_password.jsp", params);

                Platform.runLater(() -> {
                    btnUpdate.setDisable(false);
                    btnUpdate.setText("Update Security Settings");

                    if (response != null && response.trim().startsWith("{")) {
                        JSONObject result = new JSONObject(response);
                        if (result.optBoolean("success", false)) {
                            showAlert(Alert.AlertType.INFORMATION, "Success", "Password updated.");
                            clearFields();
                        } else {
                            showAlert(Alert.AlertType.ERROR, "Security Error", result.optString("message"));
                        }
                    }
                });
            } catch (Exception e) {
                Platform.runLater(() -> {
                    btnUpdate.setDisable(false);
                    btnUpdate.setText("Update Security Settings");
                    showAlert(Alert.AlertType.ERROR, "Connection Error", "Could not reach the server.");
                });
            }
        }).start();
    }

    private void clearFields() {
        fieldCurrentPass.clear();
        fieldNewPass.clear();
        fieldConfirmPass.clear();
    }

    private void showAlert(Alert.AlertType type, String title, String content) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(content);
        alert.showAndWait();
    }

    public void setOnProfilePhotoUpdated(Runnable onProfilePhotoUpdated) {
        this.onProfilePhotoUpdated = onProfilePhotoUpdated;
    }
}
