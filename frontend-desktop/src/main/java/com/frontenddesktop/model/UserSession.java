package com.frontenddesktop.model;

public class UserSession {
    private static int userId;
    private static String username;
    private static String role;
    private static String department;
    private static String fullName; // Added to support Chat UI and channel listing
    private static String profilePhotoPath;
    private static String phone;
    private static String bio;
    private static String personalEmail;

    // Updated to include department and fullName [cite: 2026-01-21]
    public static void init(int id, String user, String r, String dept, String name, String photoPath,
                            String phoneNumber, String userBio, String email) {
        userId = id;
        username = user;
        role = r;
        department = dept;
        fullName = name;
        profilePhotoPath = photoPath;
        phone = phoneNumber;
        bio = userBio;
        personalEmail = email;
    }

    public static int getUserId() { return userId; }
    public static String getUsername() { return username; }
    public static String getRole() { return role; }
    public static String getUserDept() { return department; }

    // Support for personalizing "Chatting as..." labels
    public static String getFullName() { return fullName; }
    public static String getProfilePhotoPath() { return profilePhotoPath; }
    public static void setProfilePhotoPath(String photoPath) { profilePhotoPath = photoPath; }
    public static String getPhone() { return phone; }
    public static void setPhone(String phoneNumber) { phone = phoneNumber; }
    public static String getBio() { return bio; }
    public static void setBio(String userBio) { bio = userBio; }
    public static String getPersonalEmail() { return personalEmail; }
    public static void setPersonalEmail(String email) { personalEmail = email; }

    public static void clean() {
        userId = 0;
        username = null;
        role = null;
        department = null;
        fullName = null;
        profilePhotoPath = null;
        phone = null;
        bio = null;
        personalEmail = null;
    }
}
