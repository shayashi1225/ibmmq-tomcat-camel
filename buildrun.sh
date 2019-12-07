#!/bin/bash
mvn clean package
make docker-build
docker run --privileged --net host --rm quay.io/eformat/ibmmq-tomcat-camel:latest
