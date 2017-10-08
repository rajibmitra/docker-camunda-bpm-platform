.PHONY: all
all: tomcat wildfly ee snapshot snapshot-ee

.PHONY: tomcat
tomcat:
	docker build -t tomcat .

.PHONY: wildfly
wildfly:
	docker build -t wildfly --build-arg DISTRO=wildfly .

.PHONY: ee
ee:
	docker build -t tomcat-ee --build-arg EE=true --build-arg NEXUS_USER=$(NEXUS_USER) --build-arg NEXUS_PASS=$(NEXUS_PASS) --build-arg VERSION=7.6.7 .

.PHONY: snapshot
snapshot:
	docker build -t snapshot --build-arg VERSION=7.8.0-SNAPSHOT .

.PHONY: snapshot-ee
snapshot-ee:
	docker build -t snapshot-ee --build-arg EE=true --build-arg NEXUS_USER=$(NEXUS_USER) --build-arg NEXUS_PASS=$(NEXUS_PASS) --build-arg VERSION=7.8.0-SNAPSHOT .

