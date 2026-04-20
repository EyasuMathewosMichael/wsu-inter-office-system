package com.frontenddesktop;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import java.io.IOException;
import java.net.URL;

public class MainApp extends Application {

    @Override
    public void start(Stage primaryStage) {
        try {
            // Ensure the stage starts with standard OS decorations
            // This is the default, but we'll be explicit
            primaryStage.initStyle(StageStyle.DECORATED);

            FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/frontenddesktop/view/Login.fxml"));
            Parent root = loader.load();

            primaryStage.setTitle("WSU - Inter-Office Communication System");

            // Standard Login Dimensions
            Scene scene = new Scene(root, 400, 500);

            // Verified CSS loading
            URL cssUrl = getClass().getResource("/com/frontenddesktop/styles/style.css");
            if (cssUrl != null) {
                scene.getStylesheets().add(cssUrl.toExternalForm());
            }

            primaryStage.setScene(scene);

            // Login is usually fixed size
            primaryStage.setResizable(false);
            primaryStage.centerOnScreen();

            primaryStage.setOnCloseRequest(event -> {
                Platform.exit();
                System.exit(0);
            });

            primaryStage.show();

        } catch (IOException e) {
            System.err.println("Critical Error: Could not load Login.fxml.");
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}