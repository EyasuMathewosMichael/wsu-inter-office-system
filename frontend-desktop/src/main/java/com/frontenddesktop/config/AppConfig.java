package com.frontenddesktop.config;

import java.io.InputStream;
import java.util.Properties;

public final class AppConfig {
    private static final String DEFAULT_BACKEND_BASE_URL = "http://localhost:8080/backend-web";
    private static final Properties PROPERTIES = loadProperties();

    private AppConfig() {
    }

    public static String getBackendBaseUrl() {
        String systemOverride = System.getProperty("iocs.backend.base_url");
        if (systemOverride != null && !systemOverride.trim().isEmpty()) {
            return normalizeBaseUrl(systemOverride);
        }

        String envOverride = System.getenv("IOCS_BACKEND_BASE_URL");
        if (envOverride != null && !envOverride.trim().isEmpty()) {
            return normalizeBaseUrl(envOverride);
        }

        return normalizeBaseUrl(PROPERTIES.getProperty("backend.base_url", DEFAULT_BACKEND_BASE_URL));
    }

    public static String resolve(String relativePath) {
        String normalizedPath = relativePath == null ? "" : relativePath.trim();
        if (normalizedPath.startsWith("/")) {
            normalizedPath = normalizedPath.substring(1);
        }
        return getBackendBaseUrl() + "/" + normalizedPath;
    }

    public static String apiUrl(String jspName) {
        return resolve("api/" + jspName);
    }

    public static String adminUrl(String pageName) {
        return resolve("admin/" + pageName);
    }

    private static Properties loadProperties() {
        Properties props = new Properties();
        try (InputStream in = AppConfig.class.getResourceAsStream("/com/frontenddesktop/config/app.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception ignored) {
        }
        return props;
    }

    private static String normalizeBaseUrl(String value) {
        String normalized = value == null ? DEFAULT_BACKEND_BASE_URL : value.trim();
        while (normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized.isEmpty() ? DEFAULT_BACKEND_BASE_URL : normalized;
    }
}
