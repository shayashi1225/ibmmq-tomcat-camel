#!/bin/bash
mvn clean package
docker build -f Dockerfile -t ibm-tomcat-camel .
docker run --privileged --net host --rm ibm-tomcat-camel:latest
