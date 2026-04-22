#!/bin/sh
set -eu

CATALINA_HOME="${CATALINA_HOME:-/usr/local/tomcat}"
APP_DIR="${CATALINA_HOME}/webapps/backend-web"
WEB_INF_DIR="${APP_DIR}/WEB-INF"
SERVER_XML="${CATALINA_HOME}/conf/server.xml"
PORT_VALUE="${PORT:-10000}"
UPLOAD_BASE_DIR="${UPLOAD_BASE_DIR:-/var/data/wsu-iocs}"
SEED_IMG_DIR="/opt/render-seed/assets-img"

mkdir -p "${WEB_INF_DIR}"

# Render assigns the public HTTP port dynamically.
sed -i "s/port=\"8080\" protocol=\"HTTP\\/1\\.1\"/port=\"${PORT_VALUE}\" protocol=\"HTTP\\/1\\.1\"/" "${SERVER_XML}"

cat > "${WEB_INF_DIR}/db.properties" <<EOF
db.driver=${DB_DRIVER:-com.mysql.cj.jdbc.Driver}
db.url=${DB_URL:-jdbc:mysql://localhost:3306/inter_office_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC}
db.username=${DB_USERNAME:-root}
db.password=${DB_PASSWORD:-}
EOF

if [ -n "${MAIL_SMTP_HOST:-}" ] && \
   [ -n "${MAIL_SMTP_PORT:-}" ] && \
   [ -n "${MAIL_SMTP_USERNAME:-}" ] && \
   [ -n "${MAIL_SMTP_PASSWORD:-}" ] && \
   [ -n "${MAIL_FROM_EMAIL:-}" ]; then
cat > "${WEB_INF_DIR}/mail.properties" <<EOF
smtp.host=${MAIL_SMTP_HOST}
smtp.port=${MAIL_SMTP_PORT}
smtp.username=${MAIL_SMTP_USERNAME}
smtp.password=${MAIL_SMTP_PASSWORD}
smtp.from_email=${MAIL_FROM_EMAIL}
smtp.from_name=${MAIL_FROM_NAME:-WSU IOCS}
EOF
else
    rm -f "${WEB_INF_DIR}/mail.properties"
fi

mkdir -p \
    "${UPLOAD_BASE_DIR}/assets/img" \
    "${UPLOAD_BASE_DIR}/assets/uploads" \
    "${UPLOAD_BASE_DIR}/assets/uploads/announcements" \
    "${UPLOAD_BASE_DIR}/assets/uploads/tasks"

if [ -d "${SEED_IMG_DIR}" ]; then
    cp -Rn "${SEED_IMG_DIR}/." "${UPLOAD_BASE_DIR}/assets/img/" 2>/dev/null || true
fi

rm -rf "${APP_DIR}/assets/img" "${APP_DIR}/assets/uploads"
ln -sfn "${UPLOAD_BASE_DIR}/assets/img" "${APP_DIR}/assets/img"
ln -sfn "${UPLOAD_BASE_DIR}/assets/uploads" "${APP_DIR}/assets/uploads"

mkdir -p \
    "${APP_DIR}/assets/uploads/announcements" \
    "${APP_DIR}/assets/uploads/tasks" \
    "${APP_DIR}/assets/img"

exec "$@"
