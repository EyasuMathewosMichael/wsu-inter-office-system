package com.frontenddesktop.util;

public final class ProfileImageUtil {
    private static final String PROFILE_IMAGE_BASE_URL = "http://localhost:8080/backend-web/assets/img/";

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

        return PROFILE_IMAGE_BASE_URL + fileName;
    }
}
