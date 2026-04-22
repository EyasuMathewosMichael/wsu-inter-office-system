FROM maven:3.9.9-eclipse-temurin-11 AS build

WORKDIR /app

COPY pom.xml ./
COPY src ./src

RUN mvn -DskipTests package

FROM tomcat:9.0-jdk11-temurin

ENV CATALINA_HOME=/usr/local/tomcat

WORKDIR ${CATALINA_HOME}

RUN rm -rf webapps/*

COPY --from=build /app/target/backend-web.war /tmp/backend-web.war

RUN mkdir -p webapps/backend-web \
    && cd webapps/backend-web \
    && jar -xf /tmp/backend-web.war \
    && rm /tmp/backend-web.war

RUN mkdir -p /opt/render-seed \
    && cp -R webapps/backend-web/assets/img /opt/render-seed/assets-img

COPY docker/render-entrypoint.sh /usr/local/bin/render-entrypoint.sh

RUN chmod +x /usr/local/bin/render-entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]
CMD ["catalina.sh", "run"]
