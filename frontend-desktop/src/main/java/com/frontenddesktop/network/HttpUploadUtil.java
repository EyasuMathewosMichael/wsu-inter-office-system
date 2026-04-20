package com.frontenddesktop.network;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;

public class HttpUploadUtil {
    public static String uploadFile(String targetURL, File file, String taskId) throws Exception {
        String boundary = "===" + System.currentTimeMillis() + "===";
        HttpURLConnection conn = (HttpURLConnection) new URL(targetURL).openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

        try (PrintWriter writer = new PrintWriter(new OutputStreamWriter(conn.getOutputStream(), "UTF-8"), true)) {
            // Task ID field
            writer.println("--" + boundary);
            writer.println("Content-Disposition: form-data; name=\"task_id\"");
            writer.println();
            writer.println(taskId);

            // File field
            writer.println("--" + boundary);
            writer.println("Content-Disposition: form-data; name=\"attachment\"; filename=\"" + file.getName() + "\"");
            writer.println("Content-Type: " + Files.probeContentType(file.toPath()));
            writer.println();
            writer.flush();
            Files.copy(file.toPath(), conn.getOutputStream());
            writer.println();

            writer.println("--" + boundary + "--");
        }
        return (conn.getResponseCode() == 200) ? "Success" : "Failed";
    }
}