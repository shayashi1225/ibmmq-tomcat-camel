FROM registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat8-openshift:1.4
COPY target/ROOT.war /opt/webserver/webapps/
COPY target/ibmmq-tomcat-camel/WEB-INF/classes/application.properties /opt/webserver/webapps/
COPY ocp/configuration/* /opt/webserver/conf/
ENV AB_JOLOKIA_PORT=8778 AB_JOLOKIA_PASSWORD_RANDOM=false AB_JOLOKIA_USER=jolokia AB_JOLOKIA_PASSWORD=jolokia AB_JOLOKIA_AUTH_OPENSHIFT=false AB_JOLOKIA_HTTPS="" AB_JOLOKIA_OPTS="useSslClientAuthentication=true,extraClientCheck=true,protocol=https,clientPrincipal=cn=hawtio-online.hawtio.svc,caCert=/opt/webserver/webapps/ca.crt"
ENV JAVA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
