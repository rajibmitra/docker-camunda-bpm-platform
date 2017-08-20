VERSION=7.8.0-SNAPSHOT
SUBDIRS = $(shell find . -mindepth 2 -maxdepth 2 -type f -name Makefile -exec dirname {} \;)

# pull parent images, build images and run tests
all: pull-from build test

# build the image
build:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e build ; \
    done

# pull image from registry
pull:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e pull ; \
    done

# pull parent image
pull-from:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e pull-from ; \
    done

# test image
test:
	cd test && ./test.sh

# tag images
tag:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e tag ; \
    done

# tag latest images
tag-latest:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e tag-latest ; \
    done

# push images to registry
push:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e push ; \
    done

# push latest images to registry
push-latest:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e push-latest ; \
    done

# remove images with all tags
rmi:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e rmi ; \
    done

# remove latest images with all tags
rmi-latest:
	for dir in $(SUBDIRS) ; do \
        make -C  $$dir -e rmi-latest ; \
    done

.PHONY: build pull pull-from test tag tag-latest push push-latest publish rmi rmi-latest
