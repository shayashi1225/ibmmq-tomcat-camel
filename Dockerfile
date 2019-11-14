FROM registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat8-openshift:1.4
COPY target/ROOT.war /opt/webserver/webapps/
COPY ocp/configuration/* /opt/webserver/conf/