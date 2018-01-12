# Use jbossdemocentral/developer as the base
FROM jbossdemocentral/developer

# Maintainer details
MAINTAINER Andrew Block, Eric D. Schabell

# Environment Variables 
ENV BPMS_HOME /opt/jboss/bpms/jboss-eap-7.0
ENV BPMS_VERSION_MAJOR 6
ENV BPMS_VERSION_MINOR 4
ENV BPMS_VERSION_MICRO 0
ENV BPMS_VERSION_PATCH GA

ENV EAP_VERSION_MAJOR 7
ENV EAP_VERSION_MINOR 0
ENV EAP_VERSION_MICRO 0

ENV DV_HOME /opt/jboss/bpms/jboss-dv-6.3
ENV DV_VERSION_MAJOR 6
ENV DV_VERSION_MINOR 3
ENV DV_VERSION_MICRO 0
ENV DV_VERSION_PATCH 1

ENV EAP_INSTALLER=jboss-eap-$EAP_VERSION_MAJOR.$EAP_VERSION_MINOR.$EAP_VERSION_MICRO-installer.jar
ENV BPMS_DEPLOYABLE=jboss-bpmsuite-$BPMS_VERSION_MAJOR.$BPMS_VERSION_MINOR.$BPMS_VERSION_MICRO.$BPMS_VERSION_PATCH-deployable-eap7.x.zip
ENV DV_INSTALLER=jboss-dv-$DV_VERSION_MAJOR.$DV_VERSION_MINOR.$DV_VERSION_MICRO-$DV_VERSION_PATCH-installer.jar

# ADD Installation and Management Files
COPY support/installation-eap support/installation-eap.variables support/installation-dv support/installation-dv.variables installs/$BPMS_DEPLOYABLE installs/$EAP_INSTALLER installs/$DV_INSTALLER support/fix-permissions /opt/jboss/

# Update Permissions on Installers
USER root
RUN usermod -g root jboss && \
    chown 1000:root /opt/jboss/$EAP_INSTALLER /opt/jboss/$BPMS_DEPLOYABLE /opt/jboss/$DV_INSTALLER

# Prepare and run installer and cleanup installation components
RUN sed -i "s:<installpath>.*</installpath>:<installpath>$BPMS_HOME</installpath>:" /opt/jboss/installation-eap \
    && java -jar /opt/jboss/$EAP_INSTALLER  /opt/jboss/installation-eap -variablefile /opt/jboss/installation-eap.variables \
    && unzip -qo /opt/jboss/$BPMS_DEPLOYABLE  -d $BPMS_HOME/.. \
    && /opt/jboss/fix-permissions $BPMS_HOME \
    && sed -i "s:<installpath>.*</installpath>:<installpath>$DV_HOME</installpath>:" /opt/jboss/installation-dv \
    && java -jar /opt/jboss/$DV_INSTALLER /opt/jboss/installation-dv -variablefile /opt/jboss/installation-dv.variables \
    && /opt/jboss/fix-permissions $DV_HOME \
    && rm -rf /opt/jboss/$BPMS_DEPLOYABLE /opt/jboss/$EAP_INSTALLER /opt/jboss/$DV_INSTALLER \
    && rm -rf /opt/jboss/installation-eap* /opt/jboss/installation-dv* \
    && rm -rf $BPMS_HOME/standalone/configuration/standalone_xml_history/ $DV_HOME/standalone/configuration/standalone_xml_history/ \
    && $BPMS_HOME/bin/add-user.sh -a -r ApplicationRealm -u erics -p bpmsuite1! -ro analyst,admin,manager,user,kie-server,kiemgmt,rest-all --silent

# Copy demo and support files
COPY projects /opt/jboss/bpms-projects
COPY support/bpm-suite-demo-niogit $BPMS_HOME/bin/.niogit
COPY support/userinfo.properties $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/
COPY support/standalone.xml $BPMS_HOME/standalone/configuration/
COPY support/teiidfiles/data/* $DV_HOME/standalone/configuration/
COPY support/teiidfiles/standalone.xml $DV_HOME/standalone/configuration/
COPY support/teiidfiles/vdb/* $DV_HOME/standalone/deployments/
COPY support/teiidfiles/dashboard/* $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/deployments/
COPY support/teiid-8.12.5.redhat-8-jdbc.jar $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/lib/
COPY support/start.sh /opt/jboss/

# Run Demo Maven build and cleanup
RUN mvn clean install -f /opt/jboss/bpms-projects/pom.xml \
  && cp -r /opt/jboss/bpms-projects/acme-demo-flight-service/target/acme-flight-service-1.0.war $BPMS_HOME/standalone/deployments/ \
  && cp -r /opt/jboss/bpms-projects/acme-demo-hotel-service/target/acme-hotel-service-1.0.war $BPMS_HOME/standalone/deployments/ \
  && cp -r /opt/jboss/bpms-projects/acme-data-model/target/acmeDataModel-1.0.jar $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/lib/ \
  && cp -r /opt/jboss/bpms-projects/external-client-ui-form/target/external-client-ui-form-1.0.war $BPMS_HOME/standalone/deployments/ \
  && chown -R 1000:root $BPMS_HOME \
  && /opt/jboss/fix-permissions $BPMS_HOME/bin/.niogit \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/configuration/standalone.xml \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/acme-flight-service-1.0.war \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/acme-hotel-service-1.0.war \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/lib/acmeDataModel-1.0.jar \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/external-client-ui-form-1.0.war \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/business-central.war/WEB-INF/classes/userinfo.properties \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/deployments/bookings.workspace \
  && /opt/jboss/fix-permissions $BPMS_HOME/standalone/deployments/dashbuilder.war/WEB-INF/deployments/travelandhotelKPIs.kpis \
  && /opt/jboss/fix-permissions $DV_HOME/standalone/configuration/standalone.xml \
  && /opt/jboss/fix-permissions $DV_HOME/standalone/configuration/flights-source-schema.sql \
  && /opt/jboss/fix-permissions $DV_HOME/standalone/configuration/hotels-source-schema.sql \
  && /opt/jboss/fix-permissions $DV_HOME/standalone/deployments/travel-vdb.xml \
  && /opt/jboss/fix-permissions $DV_HOME/standalone/deployments/travel-vdb.xml.dodeploy \
  && /opt/jboss/fix-permissions /etc/passwd \
  && /opt/jboss/fix-permissions /etc/group \
  && /opt/jboss/fix-permissions /opt/jboss/start.sh \
  && /opt/jboss/fix-permissions /opt/jboss/.m2 \
  && rm -rf /opt/jboss/bpms-projects \
  && chmod +x /opt/jboss/start.sh 

# Run as JBoss 
USER 1000

# Expose Ports
EXPOSE 9990 9999 8080 31000 10090 10099 8180

# Default Command
CMD ["/bin/bash"]

# Helper script
ENTRYPOINT ["/opt/jboss/start.sh"]
