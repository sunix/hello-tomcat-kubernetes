# from the root project folder:
# $ mvn clean install
# $ docker build -f src/main/docker/Dockerfile -t quay.io/sunix/hello-tomcat .
# $ docker run quay.io/sunix/hello-tomcat

# https://hub.docker.com/_/tomcat
FROM docker.io/tomcat:10.1-jdk17-openjdk

COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
