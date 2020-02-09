# Using multi stage docker build
# Stage - 1  Prepare the build artifacts 

FROM quay.io/rhdevelopers/tutorial-tools:0.0.3 as build

# If you want to use nexus or any other maven repository manager then
# uncomment this to point to the repo manager
ENV MAVEN_MIRROR_URL http://192.168.64.1:8081/nexus/content/groups/public/

RUN mkdir -p /workspace/app

COPY src /workspace/app/src
COPY pom.xml /workspace/app

WORKDIR /workspace/app

RUN /usr/local/bin/run.sh 'mvn clean package'

# Stage - 2 Prepare the final container image

FROM fabric8/java-alpine-openjdk8-jre
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV AB_ENABLED=jmx_exporter
COPY --from=build /workspace/app/target/lib/* /deployments/lib/
COPY --from=build /workspace/app/target/*-runner.jar /deployments/app.jar
ENTRYPOINT [ "/deployments/run-java.sh" ]