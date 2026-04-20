module com.frontenddesktop {
    // Required JavaFX Modules
    requires javafx.controls;
    requires javafx.fxml;
    requires javafx.graphics;
    requires javafx.web; // <--- ADDED for PDF/WebView support

    // Required Libraries from your pom.xml
    requires net.synedra.validatorfx;
    requires org.kordamp.bootstrapfx.core;
    requires com.google.gson;
    requires org.json;
    requires java.sql;
    requires java.desktop;

    // 1. Allow JavaFX to access the main app and controllers
    opens com.frontenddesktop to javafx.fxml;
    opens com.frontenddesktop.controller to javafx.fxml;

    // 2. CRITICAL: Allow JavaFX to "see" your FXML files.
    opens com.frontenddesktop.view to javafx.fxml;

    // Allow Gson to use reflection on your models to parse JSON
    opens com.frontenddesktop.model to com.google.gson, javafx.base;

    // Export packages for visibility
    exports com.frontenddesktop;
    exports com.frontenddesktop.controller;
    exports com.frontenddesktop.model;
    exports com.frontenddesktop.network;
}