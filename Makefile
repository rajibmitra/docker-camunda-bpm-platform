.PHONY: tomcat
tomcat:
	docker build -t tomcat .

.PHONY: wildfly
wildfly:
	docker build -t wildfly --build-arg DISTRO=wildfly .
