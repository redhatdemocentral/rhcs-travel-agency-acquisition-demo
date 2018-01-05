# Use jbossdemocentral/developer as the base
FROM jbossdemocentral/developer

# Maintainer details
MAINTAINER Andrew Block, Eric D. Schabell

# Environment Variables 
ENV EAP_VERSION_MAJOR 6
ENV EAP_VERSION_MINOR 4
ENV EAP_VERSION_MICRO 0

ENV BPMS_HOME /opt/jboss/bpms/jboss-bpmsuite-6.2
ENV BPMS_VERSION_MAJOR 6
ENV BPMS_VERSION_MINOR 2
ENV BPMS_VERSION_MICRO 0
ENV BPMS_VERSION_PATCH BZ-1299002 

ENV DV_VERSION_MAJOR 6
ENV DV_VERSION_MINOR 2
ENV DV_VERSION_MICRO 0
ENV DV_VERSION_BUILD redhat-3

# ADD Installation Files
COPY support/installation-eap support/installation-eap.variables support/installation-bpms support/installation-bpms.variables support/installation-dv-eap support/installation-dv-eap.variables support/installation-dv support/installation-dv.variables installs/jboss-eap-$EAP_VERSION_MAJOR.$EAP_VERSION_MINOR.$EAP_VERSION_MICRO-installer.jar installs/jboss-bpmsuite-installer-$BPMS_VERSION_MAJOR.$BPMS_VERSION_MINOR.$BPMS_VERSION_MICRO.$BPMS_VERSION_PATCH.jar installs/jboss-dv-installer-$DV_VERSION_MAJOR.$DV_VERSION_MINOR.$DV_VERSION_MICRO.$DV_VERSION_BUILD.jar /opt/jboss/

# Configure project prerequisites and run installer and cleanup installation components
RUN sed -i "s:<installpath>.*</installpath>:<installpath>$BPMS_HOME</installpath>:" /opt/jboss/installation-eap \
  && java -jar /opt/jboss/jboss-eap-$EAP_VERSION_MAJOR.$EAP_VERSION_MINOR.$EAP_VERSION_MICRO-installer.jar /opt/jboss/installation-eap -variablefile /opt/jboss/installation-eap.variables \
  && rm -rf /opt/jboss/installation-eap /opt/jboss/installation-eap.variables \
  && sed -i "s:<installpath>.*</installpath>:<installpath>$BPMS_HOME</installpath>:" /opt/jboss/installation-bpms \
  && java -jar /opt/jboss/jboss-bpmsuite-installer-$BPMS_VERSION_MAJOR.$BPMS_VERSION_MINOR.$BPMS_VERSION_MICRO.$BPMS_VERSION_PATCH.jar  /opt/jboss/installation-bpms -variablefile /opt/jboss/installation-bpms.variables \
  && rm -rf /opt/jboss/jboss-bpmsuite-installer-$BPMS_VERSION_MAJOR.$BPMS_VERSION_MINOR.$BPMS_VERSION_MICRO.$BPMS_VERSION_PATCH.jar /opt/jboss/installation-bpms /opt/jboss/installation-bpms.variables $BPMS_HOME/standalone/configuration/standalone_xml_history/* \
  && sed -i "s:<installpath>.*</installpath>:<installpath>$DV_HOME</installpath>:" /opt/jboss/installation-dv-eap \
  && java -jar /opt/jboss/jboss-eap-$EAP_VERSION_MAJOR.$EAP_VERSION_MINOR.$EAP_VERSION_MICRO-installer.jar /opt/jboss/installation-dv-eap -variablefile /opt/jboss/installation-dv-eap.variables \
  && rm -rf /opt/jboss/jboss-eap-$EAP_VERSION_MAJOR.$EAP_VERSION_MINOR.$EAP_VERSION_MICRO-installer.jar /opt/jboss/installation-dv-eap /opt/jboss/installation-dv-eap.variables \
  && sed -i "s:<installpath>.*</installpath>:<installpath>$DV_HOME</installpath>:" /opt/jboss/installation-dv \
  && java -jar /opt/jboss/jboss-dv-installer-$DV_VERSION_MAJOR.$DV_VERSION_MINOR.$DV_VERSION_MICRO.$DV_VERSION_BUILD.jar  /opt/jboss/installation-dv -variablefile /opt/jboss/installation-dv.variables \
  && rm -rf jboss-dv-installer-$DV_VERSION_MAJOR.$DV_VERSION_MINOR.$DV_VERSION_MICRO.$DV_VERSION_BUILD.jar /opt/jboss/installation-dv /opt/jboss/installation-dv.variables $DV_HOME/standalone/configuration/standalone_xml_history/*

# Copy demo, support files and helper script
COPY projects /opt/jboss/bpms-projects
COPY support/bpm-suite-demo-niogit $BPMS_HOME/bin/.niogit/
COPY support/application-roles.properties support/standalone.xml $BPMS_HOME/standalone/configuration/
COPY support/userinfo.properties $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/
COPY support/CustomWorkItemHandlers.conf $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/
COPY support/teiidfiles/data/flights-source-schema.sql support/teiidfiles/data/hotels-source-schema.sql support/teiidfiles/standalone.xml $DV_HOME/standalone/configuration/
COPY support/teiidfiles/vdb/travel-vdb.xml support/teiidfiles/vdb/travel-vdb.xml.dodeploy $DV_HOME/standalone/deployments/
COPY support/teiidfiles/dashboard/* $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/deployments/
COPY support/docker/start.sh /opt/jboss/

# Swtich back to root user to perform build and cleanup
USER root

# Run Maven Build, adjust permissions and cleanup
RUN mvn clean install -f /opt/jboss/bpms-projects/pom.xml \
&& cp -r /opt/jboss/bpms-projects/acme-demo-flight-service/target/acme-flight-service-1.0.war $BPMS_HOME/standalone/deployments/ \
&& cp -r /opt/jboss/bpms-projects/acme-demo-hotel-service/target/acme-hotel-service-1.0.war $BPMS_HOME/standalone/deployments/ \
&& cp -r /opt/jboss/bpms-projects/acme-data-model/target/acmeDataModel-1.0.jar $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/lib/ \
&& cp -r /opt/jboss/bpms-projects/external-client-ui-form/target/external-client-ui-form-1.0.war $BPMS_HOME/standalone/deployments/ \
&& cp -r $DV_HOME/dataVirtualization/jdbc/teiid-8.*.jar $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/lib/ \
&& chown -R 1000:1000 $BPMS_HOME/bin/.niogit $BPMS_HOME/standalone/configuration/application-roles.properties $BPMS_HOME/standalone/configuration/standalone.xml $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/lib/teiid-8.*.jar $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/userinfo.properties $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/CustomWorkItemHandlers.conf $BPMS_HOME/standalone/deployments/acme-flight-service-1.0.war $BPMS_HOME/standalone/deployments/acme-hotel-service-1.0.war $BPMS_HOME/standalone/deployments/external-client-ui-form-1.0.war $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/lib/acmeDataModel-1.0.jar $DV_HOME/standalone/configuration/flights-source-schema.sql $DV_HOME/standalone/configuration/hotels-source-schema.sql $DV_HOME/standalone/configuration/standalone.xml $DV_HOME/standalone/configuration/standalone.xml $DV_HOME/standalone/deployments/travel-vdb.xml $DV_HOME/standalone/deployments/travel-vdb.xml.dodeploy $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/deployments/ /opt/jboss/start.sh \
&& rm -rf ~/.m2/repository /opt/jboss/bpms-projects \
&& chmod +x /opt/jboss/start.sh

# Run as JBoss 
USER 1000

# Expose Ports
EXPOSE 9990 9999 8080 31000 10090 10099 8180

# Default Command
CMD ["/bin/bash"]

# Helper script
ENTRYPOINT ["/opt/jboss/start.sh"]
