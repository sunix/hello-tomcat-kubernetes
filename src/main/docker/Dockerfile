# from the root project folder:
# $ mvn clean install
# $ docker build -f src/main/docker/Dockerfile -t quay.io/sunix/hello-tomcat .
# $ docker run quay.io/sunix/hello-tomcat

# https://hub.docker.com/_/tomcat
FROM docker.io/tomcat:9.0-jdk11-openjdk

COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
