package com.frontenddesktop.util;

import com.frontenddesktop.config.AppConfig;

public final class ProfileImageUtil {
    private ProfileImageUtil() {
    }

    public static String buildProfileImageUrl(String storedPath) {
        if (storedPath == null || storedPath.trim().isEmpty()) {
            return null;
        }

        String normalized = storedPath.replace("\\", "/").trim();
        String fileName = normalized.substring(normalized.lastIndexOf('/') + 1);
        if (!fileName.matches("[a-zA-Z0-9._-]+")) {
            return null;
        }

        return AppConfig.resolve("assets/img/" + fileName);
    }
}

