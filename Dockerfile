FROM registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat8-openshift:1.4
COPY target/ROOT.war /opt/webserver/webapps/
COPY target/ibmmq-tomcat-camel/WEB-INF/classes/application.properties /opt/webserver/webapps/
COPY ocp/configuration/* /opt/webserver/conf/
ENV JAVA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
