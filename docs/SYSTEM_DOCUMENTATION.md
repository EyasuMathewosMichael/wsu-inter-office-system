# WSU Inter-Office Communication System

## 1. Overview

The WSU Inter-Office Communication System is a two-client university communication and coordination platform built for the School of Informatics at Wolaita Sodo University.

It has:

- a JSP/Servlet-based web application for `Admin`
- a JavaFX desktop application for `Dept Head` and `Staff`
- a MySQL/MariaDB database named `inter_office_db`

The system supports:

- user management
- department-based announcements
- direct and department chat
- task assignment and submission
- profile management
- activity/traffic log viewing on the admin side

## 2. Intended Role Model

### Admin

- uses the web portal only
- manages users
- manages announcements
- uses admin chat
- views traffic logs
- edits own admin profile

### Dept Head

- uses the desktop application
- views department overview
- creates and edits tasks
- reviews completed staff submissions
- posts department announcements
- participates in department and direct chat
- updates own profile and password

### Staff

- uses the desktop application
- views assigned tasks
- submits task replies and completion files
- reads department announcements
- participates in department and direct chat
- updates own profile and password

## 3. High-Level Architecture

### Backend

- Module: `backend-web`
- Packaging: Maven WAR
- Runtime: Apache Tomcat
- View/API style: JSP pages used both for HTML pages and JSON endpoints
- Database access: direct JDBC from JSPs

### Desktop Client

- Module: `frontend-desktop`
- Runtime: Java 17 + JavaFX 17
- UI: FXML + controller pattern
- Networking: plain `HttpURLConnection` helper utilities
- Data format: JSON over HTTP

### Database

- Engine expected: MySQL/MariaDB
- Database name: `inter_office_db`
- Reference dump: `docs/inter_office_db (4).sql`

## 4. Repository Structure

```text
inter-office-system/
├── backend-web/
│   ├── pom.xml
│   └── src/main/webapp/
│       ├── index.jsp
│       ├── logout.jsp
│       ├── admin/
│       ├── api/
│       ├── assets/
│       └── WEB-INF/
├── frontend-desktop/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/frontenddesktop/
│       └── resources/com/frontenddesktop/
└── docs/
    ├── inter_office_db (4).sql
    ├── System_Architecture.pdf
    ├── Use_Case_Diagrams.pdf
    └── SYSTEM_DOCUMENTATION.md
```

## 5. Technology Stack

### Backend

- Java 11
- JSP / Servlet API 4.0.1
- Apache Tomcat
- MySQL Connector/J 8.0.33
- `org.json`
- Gson 2.10.1
- jBCrypt 0.4
- Commons FileUpload / Commons IO

### Desktop

- Java 17
- JavaFX 17.0.14
- Gson 2.10.1
- `org.json`
- ValidatorFX
- BootstrapFX

## 6. Build and Packaging

### Backend

Defined in `backend-web/pom.xml`.

- packaging: `war`
- final artifact name: `backend-web.war`

Typical build:

```bash
cd backend-web
mvn clean package
```

### Desktop

Defined in `frontend-desktop/pom.xml`.

Typical run:

```bash
cd frontend-desktop
mvn javafx:run
```

Typical build:

```bash
cd frontend-desktop
mvn clean package
```

## 7. Runtime Configuration

### Local Backend Web Context

The web app runs under this base URL:

```text
http://localhost:8080/backend-web
```

The common browser entry pages are:

```text
http://localhost:8080/backend-web/index.jsp
http://localhost:8080/backend-web/admin/login.jsp
```

### Public Deployment Profile

The current public deployment uses:

- backend hosting: Render
- database hosting: Aiven MySQL
- public base URL: `https://wsu-inter-office-system-backend.onrender.com/`

Public browser entry pages:

```text
https://wsu-inter-office-system-backend.onrender.com/
https://wsu-inter-office-system-backend.onrender.com/admin/login.jsp
```

Current operational note:

- the Render deployment is on the free plan
- uploaded files are served correctly, but file storage is ephemeral and may be lost after redeploys or restarts

### Live Tomcat Path Used in This Project

The repository source most often synced during development is:

```text
C:\xampp\tomcat\webapps\backend-web
```

### Local Database Connection

Local Tomcat/XAMPP development commonly uses:

```text
jdbc:mysql://localhost:3306/inter_office_db
user: root
password: (empty)
```

### Public Database Connection

The current public deployment uses an Aiven MySQL instance.

Application-level DB credentials are injected into the Render container through environment variables and written at startup into:

- `backend-web/src/main/webapp/WEB-INF/db.properties`

### Multipart Handling

Multipart-enabled JSP endpoints are registered in:

- `backend-web/src/main/webapp/WEB-INF/web.xml`

Tomcat context setting:

- `backend-web/src/main/webapp/WEB-INF/context.xml`

Current context flag:

```xml
<Context allowCasualMultipartParsing="true">
```

## 8. Web Application Modules

### Public Landing Page

File:

- `backend-web/src/main/webapp/index.jsp`

Purpose:

- public welcome page
- admin login entry point
- department showcase

### Admin Web Pages

Folder:

- `backend-web/src/main/webapp/admin/`

Main pages:

- `login.jsp`: admin login page
- `dashboard.jsp`: admin dashboard
- `manage_users.jsp`: create, update, and delete users
- `announcements.jsp`: manage announcements
- `edit_announcement.jsp`: edit announcement form
- `chat.jsp`: admin communication hub
- `profile.jsp`: admin self-profile page
- `traffic_logs.jsp`: system activity/traffic page
- `support.jsp`: extra support page
- `auth_check.jsp`: admin access guard
- `sidebar_profile.jspf`: shared sidebar profile fragment

## 9. Desktop Application Modules

### Entry Point

- `frontend-desktop/src/main/java/com/frontenddesktop/MainApp.java`

Starts the JavaFX app and loads:

- `Login.fxml`

### Main Desktop Views

#### Login

- `Login.fxml`
- `LoginController.java`

Responsibilities:

- authenticates against `api/auth.jsp`
- blocks `Admin` from entering desktop
- initializes `UserSession`

#### Dashboard

- `Dashboard.fxml`
- `DashboardController.java`

Responsibilities:

- overview cards
- task-only section
- announcement-only section
- profile view navigation
- chat view navigation
- unread polling
- role-specific wording for `Dept Head` vs `Staff`

#### Chat

- `ChatView.fxml`
- `ChatController.java`

Responsibilities:

- direct and department chat
- message polling
- replies
- attachments
- preview/download
- edit/delete own messages

#### Tasks

- `TaskItem.fxml`
- `TaskItemController.java`
- `TaskModal.fxml`
- `TaskModalController.java`
- `TaskReplyModal.fxml`
- `TaskReplyModalController.java`

Responsibilities:

- render task cards
- create/edit task
- review completed submissions
- acknowledge/close reviewed tasks
- submit staff replies
- manage task attachments

#### Announcements

- `AnnouncementItem.fxml`
- `AnnouncementItemController.java`
- `PostAnnouncementModal.fxml`
- `PostAnnouncementController.java`

Responsibilities:

- render announcement cards
- open attachments
- post department announcements for dept heads

#### Profile

- `ProfileView.fxml`
- `ProfileController.java`

Responsibilities:

- display user identity
- upload desktop profile photo
- update `phone` and `bio`
- update password

## 10. Desktop Support Classes

### Networking

- `HttpConnector.java`
  - GET requests
  - form POST requests
  - multipart POST requests
  - cookie/session handling

- `HttpUploadUtil.java`
  - additional upload utility support

### Session Model

- `UserSession.java`

Stores:

- `userId`
- `username`
- `role`
- `department`
- `fullName`
- `profilePhotoPath`
- `phone`
- `bio`

### Model Classes

- `User.java`
- `Task.java`
- `Announcement.java`
- `ChatUser.java`
- `ChatMessage.java`

### Utilities / Services

- `ProfileImageUtil.java`
- `NotificationService.java`

## 11. Database Schema

Primary schema source:

- `docs/inter_office_db (4).sql`

### 11.1 `users`

Purpose:

- stores all application users

Important columns:

- `user_id`
- `username`
- `password`
- `full_name`
- `role` enum(`Admin`, `Dept Head`, `Staff`)
- `department`
- `profile_pic_path`
- `bio`
- `phone`
- `created_at`

### 11.2 `announcements`

Purpose:

- department and global notices

Important columns:

- `announcement_id`
- `poster_id`
- `title`
- `content`
- `attachment_path`
- `target_dept`
- `created_at`

### 11.3 `chats`

Purpose:

- direct messages and department group messages

Important columns:

- `chat_id`
- `sender_id`
- `receiver_id`
  - `0` is used for department group chat
- `message`
- `reply_to_id`
- `attachment_path`
- `is_read`
- `sent_at`

### 11.4 `tasks`

Purpose:

- task assignment and completion workflow

Important columns:

- `task_id`
- `creator_id`
- `assignee_id`
- `title`
- `description`
- `priority`
- `status`
- `due_date`
- `initial_attachment_path`
- `staff_reply_text`
- `completion_attachment_path`
- `acknowledged`

Important note:

- task closure is currently driven by `acknowledged = 1`
- the database status enum does not support `Archived`

### 11.5 `task_replies`

Purpose:

- auxiliary reply table

Current note:

- the active desktop/backend workflow mainly uses `tasks.staff_reply_text` and `tasks.completion_attachment_path`
- this table exists but is not the primary path for current task submission handling

## 12. Authentication and Sessions

### Desktop Login

Endpoint:

- `api/auth.jsp`

Behavior:

- authenticates by username/password
- upgrades plaintext passwords to bcrypt on successful login
- sets session attributes
- returns JSON

Returned fields currently include:

- `user_id`
- `username`
- `role`
- `department`
- `full_name`
- `profile_pic_path`
- `phone`
- `bio`

### Admin Login

Endpoint:

- `api/auth_admin.jsp`

Behavior:

- only allows `Admin` role
- redirects to `admin/dashboard.jsp`
- upgrades plaintext passwords to bcrypt on successful login

### Session Attributes Commonly Used

- `user_id`
- `user_role`
- `user_department`
- `user_name`
- `user_pic`
- `user_phone`
- `user_bio`

Admin-specific:

- `admin_id`
- `admin_name`
- `admin_role`

## 13. API Inventory

All backend APIs are in:

- `backend-web/src/main/webapp/api/`

### 13.1 Authentication

- `auth.jsp`
  - desktop login
  - returns JSON

- `auth_admin.jsp`
  - admin web login
  - redirects

- `login_process.jsp`
  - older/legacy login processing endpoint

### 13.2 User Management

- `save_user.jsp`
  - admin creates a user
  - supports profile photo upload

- `update_user.jsp`
  - admin edits a user

- `delete_user.jsp`
  - admin deletes a user

- `users.jsp`
  - returns staff users for a dept head’s department
  - used by desktop task assignment modal

- `get_users.jsp`
  - returns chat contact list for current user
  - includes unread counts and last message preview

### 13.3 Profile and Password

- `update_profile.jsp`
  - admin self-profile update
  - supports `full_name`, `bio`, `phone`, optional password, optional photo

- `update_user_profile.jsp`
  - desktop user self-profile update
  - updates `phone` and `bio`

- `update_user_profile_photo.jsp`
  - desktop user self-photo upload

- `update_password.jsp`
  - desktop user password update

### 13.4 Announcements

- `announcements.jsp`
  - announcement creation endpoint
  - supports multipart upload

- `save_announcement.jsp`
  - legacy/alternate create endpoint

- `get_announcements.jsp`
  - returns department/global announcements

- `update_announcement.jsp`
  - announcement update
  - supports web redirect mode and JSON mode

- `delete_announcement.jsp`
  - deletes announcement
  - now intended as POST-only

### 13.5 Tasks

- `tasks.jsp`
  - central task API
  - supports:
    - GET list tasks
    - `create_task`
    - `edit_task`
    - `delete_task`
    - `staff_reply`
    - `update_status`
    - legacy `acknowledge`

- `acknowledge_task.jsp`
  - dedicated task close/acknowledge endpoint
  - preferred path for review completion

### 13.6 Chat and Messaging

- `send_message.jsp`
  - send chat message with optional file

- `get_messages.jsp`
  - fetch conversation or department chat messages

- `chat.jsp`
  - legacy or alternate chat API

- `update_message.jsp`
  - message update support

- `edit_delete_message.jsp`
  - edit/delete/remove file operations for chat messages

- `mark_as_read.jsp`
  - marks conversation messages as read

- `mark_read.jsp`
  - marks unread chat state for current user

- `check_unread.jsp`
  - unread badge check for desktop dashboard/chat icon

### 13.7 Files / Utilities

- `view_file.jsp`
  - file viewing helper

- `check_notifications.jsp`
  - checks dept head notifications for completed tasks awaiting review

## 14. Core Functional Workflows

### 14.1 Admin Creates User

1. Admin logs in through `admin/login.jsp`
2. Opens `manage_users.jsp`
3. Submits user form to `api/save_user.jsp`
4. New record is created in `users`
5. Optional profile photo is saved under backend assets

### 14.2 Desktop User Login

1. User opens desktop app
2. `LoginController` calls `api/auth.jsp`
3. Session cookie is stored by `HttpConnector`
4. `UserSession` is initialized
5. Dashboard loads

Special rule:

- if role is `Admin`, desktop login is blocked and the user is redirected to the web admin portal

### 14.3 Dept Head Creates Task

1. Dept head opens desktop `Tasks`
2. Opens `TaskModal`
3. Chooses staff from same department via `api/users.jsp`
4. Saves task through `api/tasks.jsp` with `action=create_task`
5. Optional task file goes to `initial_attachment_path`

### 14.4 Staff Submits Task Completion

1. Staff opens assigned task
2. Uses reply modal
3. Sends `staff_reply_text` and optional completion file
4. Desktop posts to `api/tasks.jsp` with `action=staff_reply`
5. Task status becomes `Completed`

### 14.5 Dept Head Reviews and Closes Task

1. Dept head opens completed task they created
2. Review modal displays staff reply and submission file
3. `Acknowledge & Close` posts to `api/acknowledge_task.jsp`
4. Backend sets `acknowledged = 1`
5. Desktop filters acknowledged tasks out of active task lists

### 14.6 Announcement Posting

1. Admin uses web announcement management or dept head uses desktop announcement modal
2. Data is posted to `api/announcements.jsp`
3. Department-specific or global announcements are stored
4. Desktop fetches via `api/get_announcements.jsp`

### 14.7 Chat

Supports:

- direct user-to-user chat
- department group chat using `receiver_id = 0`
- message replies
- file attachments
- message editing/deletion for sender
- unread tracking

## 15. File Upload Storage

Current storage patterns used by backend:

- task files:
  - `assets/uploads/tasks/`
- announcement files:
  - `assets/uploads/announcements/`
- chat attachments:
  - `assets/uploads/`
- profile images:
  - `assets/img/`

The backend normalizes stored file paths before returning them to the desktop client.

## 16. UI and Navigation Summary

### Web

- public landing page
- admin login
- admin dashboard
- admin user management
- admin announcements
- admin chat
- admin traffic logs
- admin profile

### Desktop

- login
- dashboard overview
- tasks page
- announcements page
- office chat
- profile settings

## 17. Security Notes

Current implemented protections include:

- role checks on many backend endpoints
- session-based access
- bcrypt upgrade path for old plaintext passwords
- HTML escaping in admin profile rendering
- POST-only behavior for destructive or multipart-sensitive endpoints in several places

Important limitations:

- many JDBC credentials are hard-coded
- business logic is implemented directly inside JSP files
- CSRF protection is not consistently implemented
- endpoint authorization is not centralized
- some legacy endpoints still exist and should be reviewed for overlap

## 18. Operational Notes and Constraints

### Desktop/Backend Coupling

The desktop client now supports a configurable backend base URL.

Local development commonly uses:

- `http://localhost:8080/backend-web`

Public deployment currently uses:

- `https://wsu-inter-office-system-backend.onrender.com/`

This is configured through:

- `frontend-desktop/src/main/resources/com/frontenddesktop/config/app.properties`
- `frontend-desktop/src/main/resources/com/frontenddesktop/config/app.properties.render.example`
- JVM override: `-Diocs.backend.base_url=...`
- environment override: `IOCS_BACKEND_BASE_URL`

### Password Storage

The system supports old plaintext passwords but upgrades them to bcrypt after successful authentication.

### Task Status Handling

Allowed DB task statuses from schema:

- `Pending`
- `In Progress`
- `Under Review`
- `Completed`

Active implementation currently uses:

- `Pending`
- `In Progress`
- `Completed`

Closed tasks are identified with:

- `acknowledged = 1`

### Live Deployment Practice in This Workspace

Source is edited in the repository, then selected JSPs are copied into:

```text
C:\xampp\tomcat\webapps\backend-web
```

## 19. Known Issues / Maintenance Risks

- JSP-based backend mixes UI, transport, SQL, and business rules in the same files
- duplicate or legacy API files exist for similar functions
- no obvious automated integration test suite is present
- database connection settings are duplicated across endpoints
- desktop uses polling for chat and notifications rather than push updates
- some older sample data stores absolute Windows file paths in SQL dumps

## 20. Recommended Future Improvements

### Backend

- move repeated DB config into a shared configuration layer
- replace JSP APIs with servlet/controller classes or a REST framework
- centralize authentication and authorization
- add CSRF protection for web forms
- add service and DAO layers

### Desktop

- move base URL to config
- add refresh callbacks consistently after all create/edit flows
- improve error dialogs with parsed backend messages everywhere
- add automated UI-smoke and API connectivity checks

### Database / DevOps

- use environment-based DB credentials
- add schema migration tooling
- add seed scripts for demo and test data
- add backup/restore guidance
- move public uploads to persistent object storage or a paid persistent disk

## 21. Setup Guide

### Prerequisites

- Java 11 for backend build/runtime
- Java 17 for desktop build/runtime
- Apache Tomcat
- MySQL or MariaDB
- Maven

### Database Setup

1. Create database `inter_office_db`
2. Import:

```text
docs/inter_office_db (4).sql
```

### Backend Setup

1. Build WAR:

```bash
cd backend-web
mvn clean package
```

2. Deploy the generated WAR to Tomcat as the `backend-web` application
3. Access the system at:

```text
http://localhost:8080/backend-web
```

4. If the desktop client is being used, keep its API base URL aligned with that same backend context

### Public Render Setup

Current public deployment path:

1. Push source to GitHub
2. Render deploys the backend from `render.yaml`
3. Aiven MySQL provides the live database
4. Public entry points are:

```text
https://wsu-inter-office-system-backend.onrender.com/
https://wsu-inter-office-system-backend.onrender.com/admin/login.jsp
```

Current note:

- the free Render plan is suitable for demonstration and light usage
- upload persistence is not guaranteed on the current free-tier setup

### Desktop Setup

1. Ensure backend is running on localhost
2. Run:

```bash
cd frontend-desktop
mvn javafx:run
```

## 22. Main Source Files Worth Knowing

### Backend

- `backend-web/src/main/webapp/index.jsp`
- `backend-web/src/main/webapp/admin/login.jsp`
- `backend-web/src/main/webapp/admin/dashboard.jsp`
- `backend-web/src/main/webapp/admin/manage_users.jsp`
- `backend-web/src/main/webapp/admin/announcements.jsp`
- `backend-web/src/main/webapp/admin/chat.jsp`
- `backend-web/src/main/webapp/admin/profile.jsp`
- `backend-web/src/main/webapp/api/auth.jsp`
- `backend-web/src/main/webapp/api/auth_admin.jsp`
- `backend-web/src/main/webapp/api/tasks.jsp`
- `backend-web/src/main/webapp/api/acknowledge_task.jsp`
- `backend-web/src/main/webapp/api/announcements.jsp`
- `backend-web/src/main/webapp/api/get_announcements.jsp`
- `backend-web/src/main/webapp/api/get_users.jsp`
- `backend-web/src/main/webapp/api/get_messages.jsp`
- `backend-web/src/main/webapp/api/update_user_profile.jsp`
- `backend-web/src/main/webapp/api/update_user_profile_photo.jsp`

### Desktop

- `frontend-desktop/src/main/java/com/frontenddesktop/MainApp.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/LoginController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/DashboardController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/ChatController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/TaskItemController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/TaskModalController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/TaskReplyModalController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/PostAnnouncementController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/controller/ProfileController.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/network/HttpConnector.java`
- `frontend-desktop/src/main/java/com/frontenddesktop/model/UserSession.java`

## 23. Documentation Scope Note

This document is based on the current repository state and the active source files in:

- `backend-web/src/main/webapp/`
- `frontend-desktop/src/main/`
- `docs/inter_office_db (4).sql`
