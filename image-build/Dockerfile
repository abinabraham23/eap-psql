FROM registry.access.redhat.com/ubi8:latest

LABEL maintainer="Abin Abraham"

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 \
	&& useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss

#Get utils & Java Open JDK 8
RUN yum install -y unzip \ 
		zip \
		curl \
		java-1.8.0-openjdk-devel \
		less \
		hostname \
		&& yum clean all \
		&& rm -rf /tmp/yum* \
		&& rm -rf /var/cache/yum/*

USER jboss

# Set JBoss ENVs
ENV JBOSS_HOME=/opt/jboss/jboss-eap-7.2

# Set JBoss ARGs
ARG INSTALL_ARTIFACT=jboss-eap-7.2.0.zip 
# ARG PATCH_ARTIFACT=jboss-eap-7.2.9-patch.zip
ARG APP_ARTIFACT=ROOT.war

ARG JBOSS_BASE=/opt/jboss
ARG JBOSS_CONFIG=$JBOSS_HOME/standalone/configuration
ARG JBOSS_MODULE=$JBOSS_HOME/modules

ARG MODULE_NAME="postgresql"
ARG JDBC_JAR_NAME="postgresql-42.2.18"

# Set the root for install
USER root
	    
# Set Timezone
ENV TZ "Europe/Berlin"
RUN echo "Europe/Berlin" | tee /etc/timezone

# Fetch the JBoss installation archive from context directory
# Extract the installation archive to JBOSS_HOME
COPY artifacts/${INSTALL_ARTIFACT} /tmp/
RUN unzip /tmp/${INSTALL_ARTIFACT} -d /opt/jboss \
    && rm -rf /tmp/${INSTALL_ARTIFACT} \
	&& chown -R jboss:0 ${JBOSS_HOME} \
	&& chmod -R g+rw ${JBOSS_HOME}

# COPY artifacts/${PATCH_ARTIFACT} /tmp/
# COPY apply-eap-patch.sh /tmp/patch.sh
# RUN chmod +x /tmp/patch.sh \
#     && /tmp/patch.sh

# COPY scripts/ /opt/jboss/scripts/
COPY config/* ${JBOSS_BASE}/config/
COPY modules/* ${JBOSS_BASE}/modules/

RUN chmod -R +rx ${JBOSS_BASE}/config/ \
	&& chmod -R +x ${JBOSS_BASE}/modules/ \
	&& ${JBOSS_BASE}/config/apply-eap-config.sh

# # Copy the app war file as ROOT.war to server deployment directory
COPY artifacts/${APP_ARTIFACT} ${JBOSS_HOME}/standalone/deployments/${APP_ARTIFACT}

RUN chmod -R 755 ${JBOSS_HOME} \
	&& chown -R jboss:1000 ${JBOSS_HOME} 

# Set the current user for JBoss process
USER jboss

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Open Ports
EXPOSE 8080 9990


CMD ["/opt/jboss/jboss-eap-7.2/bin/standalone.sh", "-c", "standalone-full.xml", "-b", "0.0.0.0" ]

# Set the working directory to jboss user home directory
WORKDIR ${JBOSS_HOME}
