# WSU Inter-Office Communication System

This repository contains a university inter-office communication system with:

- `backend-web`: JSP/Servlet-style web backend and admin portal
- `frontend-desktop`: JavaFX desktop app for department heads and staff
- `docs`: system documentation, diagrams, and SQL dump

## Main Modules

### `backend-web`
- Admin web portal
- Authentication APIs
- announcements, chat, tasks, profile, and password reset endpoints
- MySQL-backed JSP pages deployed on Tomcat

### `frontend-desktop`
- JavaFX desktop client
- role-based dashboard for `Dept Head` and `Staff`
- chat, tasks, announcements, and profile management

## Project Structure

```text
backend-web/
frontend-desktop/
docs/
README.md
```

## Local Setup

### Backend
1. Install Java and Tomcat.
2. Create/import the MySQL database using:
   `docs/inter_office_db (4).sql`
3. Deploy `backend-web` to Tomcat so it runs under:
   `http://localhost:8080/backend-web`
4. Configure password reset email in:
   `backend-web/src/main/webapp/WEB-INF/mail.properties`
   Start from:
   `backend-web/src/main/webapp/WEB-INF/mail.properties.example`

### Desktop
1. Install Java 17.
2. Open `frontend-desktop` in your IDE.
3. Make sure the backend is running at:
   `http://localhost:8080/backend-web`
4. Launch the JavaFX app from `MainApp.java`.

## Security Notes

- Do not commit real SMTP credentials.
- Do not commit live Tomcat deployment files.
- Do not commit generated packaging output or built artifacts.
- `mail.properties` is ignored by Git on purpose. Keep a local copy only.

## GitHub Upload Steps

If Git is installed on your machine, run these commands from the project root:

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

If GitHub asks whether to add a README or `.gitignore`, choose **no** because this repository already includes them.

## Documentation

See:

- [System Documentation](docs/SYSTEM_DOCUMENTATION.md)
- `docs/System_Architecture.pdf`
- `docs/Use_Case_Diagrams.pdf`
