package com.frontenddesktop.network;

import java.io.*;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.HttpCookie;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.List;
import java.util.Map;

/**
 * Robust Networking Utility for University Inter-Office System.
 * Optimized to prevent 500 errors by using unified DataOutputStream for Multipart.
 */
public class HttpConnector {
    private static final CookieManager COOKIE_MANAGER = new CookieManager();

    static {
        CookieHandler.setDefault(COOKIE_MANAGER);
    }

    public static String get(String urlString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        if (conn.getResponseCode() == 200) {
            return readResponse(conn);
        }
        return null;
    }

    public static void clearSession() {
        COOKIE_MANAGER.getCookieStore().removeAll();
    }

    public static String getSessionCookieHeader() {
        List<HttpCookie> cookies = COOKIE_MANAGER.getCookieStore().getCookies();
        if (cookies.isEmpty()) {
            return "";
        }

        StringBuilder header = new StringBuilder();
        for (HttpCookie cookie : cookies) {
            if (header.length() > 0) {
                header.append("; ");
            }
            header.append(cookie.getName()).append("=").append(cookie.getValue());
        }
        return header.toString();
    }

    public static String post(String urlString, Map<String, String> params) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String, String> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }

        byte[] postDataBytes = postData.toString().getBytes(StandardCharsets.UTF_8);
        try (DataOutputStream wr = new DataOutputStream(conn.getOutputStream())) {
            wr.write(postDataBytes);
        }

        if (conn.getResponseCode() == 200 || conn.getResponseCode() == 201) {
            return readResponse(conn);
        }
        return null;
    }

    /**
     * Multipart POST optimized for Department and Private Chat.
     * Uses DataOutputStream to ensure binary integrity and prevent Server 500.
     */
    public static String postMultipart(String urlString, Map<String, String> params, File uploadFile) throws Exception {
        return postMultipart(urlString, params, uploadFile, "attachment");
    }

    public static String postMultipart(String urlString, Map<String, String> params, File uploadFile, String fileFieldName) throws Exception {
        String boundary = "---" + System.currentTimeMillis();
        String LINE_FEED = "\r\n";

        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setConnectTimeout(15000);
        conn.setReadTimeout(60000);
        conn.setUseCaches(false);
        conn.setDoOutput(true);
        conn.setDoInput(true);

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
        conn.setRequestProperty("User-Agent", "JavaFX Desktop App");

        try (DataOutputStream request = new DataOutputStream(conn.getOutputStream())) {

            // 1. Write Text Parameters (sender_id, receiver_id, etc.)
            for (Map.Entry<String, String> entry : params.entrySet()) {
                request.writeBytes("--" + boundary + LINE_FEED);
                request.writeBytes("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"" + LINE_FEED);
                request.writeBytes("Content-Type: text/plain; charset=UTF-8" + LINE_FEED + LINE_FEED);
                request.write(entry.getValue().getBytes(StandardCharsets.UTF_8));
                request.writeBytes(LINE_FEED);
            }

            // 2. Write File Attachment
            if (uploadFile != null && uploadFile.exists()) {
                String fileName = uploadFile.getName();
                String contentType = Files.probeContentType(uploadFile.toPath());
                if (contentType == null) contentType = "application/octet-stream";

                request.writeBytes("--" + boundary + LINE_FEED);
                request.writeBytes("Content-Disposition: form-data; name=\"" + fileFieldName + "\"; filename=\"" + fileName + "\"" + LINE_FEED);
                request.writeBytes("Content-Type: " + contentType + LINE_FEED + LINE_FEED);

                try (FileInputStream inputStream = new FileInputStream(uploadFile)) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        request.write(buffer, 0, bytesRead);
                    }
                }
                request.writeBytes(LINE_FEED);
            }

            // 3. Finalize Boundary
            request.writeBytes("--" + boundary + "--" + LINE_FEED);
            request.flush();
        }

        int status = conn.getResponseCode();
        if (status == HttpURLConnection.HTTP_OK || status == HttpURLConnection.HTTP_CREATED) {
            return readResponse(conn);
        } else {
            // Read error stream to get the actual JSP error message
            String errorResponse = readErrorStream(conn);
            throw new IOException("Server 500: " + errorResponse);
        }
    }

    private static String readResponse(HttpURLConnection conn) throws Exception {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) response.append(inputLine);
            return response.toString();
        }
    }

    private static String readErrorStream(HttpURLConnection conn) {
        try {
            InputStream es = conn.getErrorStream();
            if (es == null) {
                return "HTTP " + conn.getResponseCode() + " (No Error Stream)";
            }
            try (BufferedReader in = new BufferedReader(new InputStreamReader(es, StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String inputLine;
                while ((inputLine = in.readLine()) != null) response.append(inputLine);
                return response.toString();
            }
        } catch (Exception e) {
            return "Failed to read stream: " + e.getMessage();
        }
    }
}
