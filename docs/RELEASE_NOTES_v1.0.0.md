# Release Notes: v1.0.0

## Summary

Initial public GitHub release of the WSU Inter-Office Communication System.

This release packages the current working state of the system across:

- the JSP/Tomcat backend web application
- the JavaFX desktop client
- the current documentation set and architecture/use-case diagrams

## Included Areas

- Admin web portal
- Desktop login for `Dept Head` and `Staff`
- Task creation, update, review, and acknowledgement flows
- Department announcements
- Office chat and attachment support
- Profile settings and profile photo handling
- Password reset using personal email
- Project documentation and generated architecture/use-case PDFs

## Documentation Assets

- `docs/SYSTEM_DOCUMENTATION.md`
- `docs/System_Architecture.pdf`
- `docs/Use_Case_Diagrams.pdf`
- `docs/screenshots/`

## Notes

- Local backend runtime remains `http://localhost:8080/backend-web`.
- Public deployment is currently available at `https://wsu-inter-office-system-backend.onrender.com/`.
- The public admin login page is `https://wsu-inter-office-system-backend.onrender.com/admin/login.jsp`.
- The public database is hosted on Aiven MySQL.
- Render is currently used on the free plan, so uploaded files are not persistent across redeploys or restarts.
- SMTP settings must be configured locally in `backend-web/src/main/webapp/WEB-INF/mail.properties`.
- Packaged desktop outputs may vary by local JavaFX and Windows packaging setup.

## Suggested GitHub Release Title

`v1.0.0 - Initial public release`

## Suggested GitHub Release Description

Initial public release of the WSU Inter-Office Communication System, including the admin web portal, JavaFX desktop client, current architecture documentation, and generated use-case diagrams.
