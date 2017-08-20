# image settings for the docker image name and tag
IMAGE_NAME=menski/whynot
VERSION=7.6.0
TAG=wildfly-$(VERSION)
ADDITIONAL_TAGS=$(VERSION)
LATEST_TAGS=wildfly wildfly-latest

# the image name which will be build
UBUNTU_IMAGE=$(IMAGE_NAME):$(TAG)
ALPINE_IMAGE=$(IMAGE_NAME):$(TAG)-alpine

# container name
CONTAINER_NAME=camunda

# the docker command which can be configured by the DOCKER_OPTS variable
DOCKER=docker $(DOCKER_OPTS)

# build the images
build:
	$(DOCKER) build -t $(UBUNTU_IMAGE) --build-arg VERSION=$(VERSION) -f Dockerfile .
	$(DOCKER) build -t $(ALPINE_IMAGE) --build-arg VERSION=$(VERSION) -f Dockerfile.alpine .

# pull images from registry
pull:
	-$(DOCKER) pull $(UBUNTU_IMAGE)
	-$(DOCKER) pull $(ALPINE_IMAGE)

# pull parent images
pull-from:
	$(DOCKER) pull ubuntu:latest
	$(DOCKER) pull alpine:latest

# tag images
tag:
	@for tag in $(ADDITIONAL_TAGS); do \
		$(DOCKER) tag $(UBUNTU_IMAGE) $(IMAGE_NAME):$$tag; \
		$(DOCKER) tag $(ALPINE_IMAGE) $(IMAGE_NAME):$$tag-alpine; \
	done

# tag latest images
tag-latest:
	@for tag in $(LATEST_TAGS); do \
		$(DOCKER) tag $(UBUNTU_IMAGE) $(IMAGE_NAME):$$tag; \
		$(DOCKER) tag $(ALPINE_IMAGE) $(IMAGE_NAME):$$tag-alpine; \
	done

# push image to registry
push:
	$(DOCKER) push $(UBUNTU_IMAGE)
	$(DOCKER) push $(ALPINE_IMAGE)
	@for tag in $(ADDITIONAL_TAGS); do \
		$(DOCKER) push $(IMAGE_NAME):$$tag; \
		$(DOCKER) push $(IMAGE_NAME):$$tag-alpine; \
	done

# push latest image to registry
push-latest:
	$(DOCKER) push $(UBUNTU_IMAGE)
	$(DOCKER) push $(ALPINE_IMAGE)
	@for tag in $(LATEST_TAGS); do \
		$(DOCKER) push $(IMAGE_NAME):$$tag; \
		$(DOCKER) push $(IMAGE_NAME):$$tag-alpine; \
	done

# pull parent image, pull image, build image and push to repository
publish: pull-from pull build test push

# run ubuntu container
run-ubuntu: rmf
	$(DOCKER) run --rm -t --name $(CONTAINER_NAME) -p 8080:8080 $(UBUNTU_IMAGE)

# run alpine container
run-alpine: rmf
	$(DOCKER) run --rm -t --name $(CONTAINER_NAME) -p 8080:8080 $(ALPINE_IMAGE)

# start ubuntu container as daemon
daemon-ubuntu: rmf
	$(DOCKER) run -d --name $(CONTAINER_NAME) -p 8080:8080 $(UBUNTU_IMAGE)

# start alpine container as daemon
daemon-alpine: rmf
	$(DOCKER) run -d --name $(CONTAINER_NAME) -p 8080:8080 $(ALPINE_IMAGE)

# start interactive ubuntu container with bash
bash-ubuntu: rmf
	$(DOCKER) run --rm -p 8080:8080 -it $(UBUNTU_IMAGE) /bin/bash

# start interactive alpine container with bash
bash-alpine: rmf
	$(DOCKER) run --rm -p 8080:8080 -it $(ALPINE_IMAGE) /bin/bash

# remove container by name
rmf:
	-$(DOCKER) rm -f $(CONTAINER_NAME)

# remove images
rmi:
	-$(DOCKER) rmi $(UBUNTU_IMAGE)
	-$(DOCKER) rmi $(ALPINE_IMAGE)
	@for tag in $(ADDITIONAL_TAGS); do \
		$(DOCKER) rmi $(IMAGE_NAME):$$tag; \
		$(DOCKER) rmi $(IMAGE_NAME):$$tag-alpine; \
	done

# remove latest images
rmi-latest:
	-$(DOCKER) rmi $(UBUNTU_IMAGE)
	-$(DOCKER) rmi $(ALPINE_IMAGE)
	@for tag in $(LATEST_TAGS); do \
		$(DOCKER) rmi $(IMAGE_NAME):$$tag; \
		$(DOCKER) rmi $(IMAGE_NAME):$$tag-alpine; \
	done

.PHONY: build pull pull-from test tag tag-latest push push-latest publish run-ubuntu run-alpine daemon-ubuntu daemon-alpine bash-ubuntu bash-alpine rmf rmi rmi-latest
