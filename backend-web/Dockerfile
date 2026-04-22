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

RUN mkdir -p webapps/ROOT \
    && cd webapps/ROOT \
    && jar -xf /tmp/backend-web.war \
    && cp -R . ../backend-web \
    && rm /tmp/backend-web.war

RUN mkdir -p /opt/render-seed \
    && cp -R webapps/ROOT/assets/img /opt/render-seed/assets-img

COPY docker/render-entrypoint.sh /usr/local/bin/render-entrypoint.sh

RUN chmod +x /usr/local/bin/render-entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]
CMD ["catalina.sh", "run"]
