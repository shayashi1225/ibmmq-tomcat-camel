# Image URL to use all building/pushing image targets
REGISTRY ?= quay.io
REPOSITORY ?= $(REGISTRY)/eformat/ibmmq-tomcat-camel

IMG := $(REPOSITORY):latest

# Docker Login
docker-login:
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD) $(REGISTRY)

# clean compile
compile:
	mvn clean package

# Build the docker image
docker-build: compile
	docker build . -t ${IMG} -f Dockerfile

# Push the docker image
docker-push: docker-build
	docker push ${IMG}

# Podman Login
podman-login:
	@podman login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD) $(REGISTRY)

# Build the oci image
podman-build:
	podman build . -t ${IMG} -f Dockerfile

# Push the oci image
podman-push: podman-build
	podman push ${IMG}
