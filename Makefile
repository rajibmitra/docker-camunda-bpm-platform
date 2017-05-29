build:
	docker build -t test .

run:
	docker run --rm -it -p 8080:8080 test bash

root:
	docker run --rm -it -u root test bash

build-ee:
	docker build --build-arg CAMUNDA_PROFILE=camunda-bpm-ee --build-arg CAMUNDA_ARTIFACT_ID=camunda-bpm-ee-tomcat --build-arg CAMUNDA_VERSION=7.7.0-ee  -t test .
