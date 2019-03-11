################################################################################
# Example of Dockerfile to setup Cognos 11.1 in a Docker container
#
# WARNING: The resulting docker image is not suitable for any production 
#          use and should be used for demonstration purposes only
#
# Copyright 2019, IBM Corporation
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
FROM consol/centos-xfce-vnc

MAINTAINER Philippe Gregoire

# VNC and HTML-VNC ports
EXPOSE 5901 6901

# Switch to root user
USER 0

#######################################################################################################
# Cognos setup
# Based on RHEL Dockerfile from dnastaci@us.ibm.com

# Cognos settings
ENV COGNOS_BASE_DIR /opt/ibm/cognos
ENV COGNOS_DIR      ${COGNOS_BASE_DIR}/analytics

ARG COGNOS_USER=cognosusr
ARG COGNOS_PW=passw0rd
ARG COGNOS_UID=1000
ARG COGNOS_GID=1000

ARG COGNOS_MEDIA_DIR=/installer/cognos

ARG COGNOS_PROPERTIES=cognosca_reponse.properties
ARG COGNOS_HOST=cognos11srv

# IBM Cognos Analytics Installer 2.0 Linux x86 Multilingual (CNV5CML)
ARG COGNOS_INSTALLER=ca_installer_linuxi38664_2.0.bin

# IBM Cognos Analytics Server 11.1.1 Linux x86 Multilingual (CNV5BML) or (CNZ14ML)
ARG COGNOS_SERVER_IMAGE=ca_server_linuxi38664_11.1.1.zip

# IBM Cognos Analytics Samples 11.0 Linux x86-64 Multilingual (CN8AFML)
ARG COGNOS_SAMPLES=ca_smpl_lnxi38664_11.0.0.15121603.bin

# Cognos Prepreq (See https://www.ibm.com/support/knowledgecenter/en/SS5R93_5.3.0/com.ibm.spectrum.sc.doc/ins_cognos_analytics_Linux_single.html)
# - glibc-2.12-1.166.el6 or later (both i686 and x86_64 packages)
# - libstdc++-4.4.7-16.el6 or later (both i686 and x86_64 packages)
# - nspr-4.9.2-1.el6 or later (both i686 and x86_64 packages)
# - nss-3.14.0.0-12.el6 or later (both i686 and x86_64 packages)
# - openmotif-2.3.3-5.el6 or later (both i686 and x86_64 packages)
#
# We also add useful utilities 
RUN yum install -y \
	which \
	unzip \
	sudo \
	nano \
	rsync \
	glibc.x86_64 glibc.i686 \
	libstdc++.x86_64 libstdc++.i686 \
	nspr.x86_64 nspr.i686 \
	nss.x86_64 nss.i686 \
	openmotif.x86_64 openmotif.i686 \
	gedit \
	&& yum clean all && rm -rf /tmp/*
	
# For the record, re: https://www.ibm.com/support/knowledgecenter/SSEP7J_11.0.0/com.ibm.swg.ba.cognos.inst_cr_winux.doc/c_inst_ulimitsettingsonunixandlinuxoperatingsystems.html
RUN \
	ulimit -f -t -u -m -n -s -v && \
	echo "Current hostname: `hostname`" && \
	echo "VNC password is ${VNC_PW}"
	
# Setup Cognos user as user 1000 and run installer
RUN \
	echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel && \
	groupadd -f -g ${COGNOS_GID} ${COGNOS_USER} && \
	useradd --help && \
	useradd -u ${COGNOS_UID} -g ${COGNOS_GID} -G wheel ${COGNOS_USER} -m && \
	echo "$COGNOS_USER:$COGNOS_PW" | chpasswd && \
	cat /etc/passwd

# Copy Cognos installer files into the container's filesystem
COPY /media/$COGNOS_INSTALLER ${COGNOS_MEDIA_DIR}/
COPY /media/$COGNOS_SERVER_IMAGE ${COGNOS_MEDIA_DIR}/
#COPY /media/$COGNOS_SAMPLES ${COGNOS_MEDIA_DIR}/

# Copy properties
COPY ${COGNOS_PROPERTIES} ${COGNOS_MEDIA_DIR}

# Run silent installer
# See also: https://www.ibm.com/support/knowledgecenter/en/SSEP7J_11.0.0/com.ibm.swg.ba.cognos.inst_cr_winux.doc/t_inst_response_templates.html
RUN \
	mkdir -p "${COGNOS_DIR}" && \
	chown -R ${COGNOS_USER}:${COGNOS_USER} "${COGNOS_BASE_DIR}" && \
	chmod -R uo+x "${COGNOS_MEDIA_DIR}/${COGNOS_INSTALLER}" && \
	echo "Running cognos silent installer with config:" && \
	echo REPO=${COGNOS_MEDIA_DIR}/${COGNOS_SERVER_IMAGE} >>${COGNOS_MEDIA_DIR}/${COGNOS_PROPERTIES} && \
	cat ${COGNOS_MEDIA_DIR}/${COGNOS_PROPERTIES} && \
	echo "BUILD_HOST=`hostname`"> ${COGNOS_BASE_DIR}/build_host.txt && \
	su - ${COGNOS_USER} -c "\"${COGNOS_MEDIA_DIR}/${COGNOS_INSTALLER}\" -f \"${COGNOS_MEDIA_DIR}/${COGNOS_PROPERTIES}\" -i silent" && \
	cp ${COGNOS_DIR}/configuration/cogstartup.xml ${COGNOS_DIR}/configuration/cogstartup.xml_`hostname` && \
	sed -i "s/`hostname`/${COGNOS_HOST}/g" ${COGNOS_DIR}/configuration/cogstartup.xml && \
	cp ${COGNOS_DIR}/configuration/cogstartup.xml ${COGNOS_DIR}/configuration/cogstartup.xml_${COGNOS_HOST}

# Copy db2jcc JDBC drivers (obtained from db2-developer-c container)
COPY /media/db2jcc.jar ${COGNOS_DIR}/drivers/
COPY /media/db2jcc4.jar ${COGNOS_DIR}/drivers/
COPY /media/db2jcc_license_cu.jar ${COGNOS_DIR}/drivers/

RUN chmod +x ${COGNOS_DIR}/drivers/db2jcc*.jar

# Set JAVA_HOME
ENV JAVA_HOME ${COGNOS_DIR}/jre

#RUN \
#	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /home/${COGNOS_USER}/.bashrc && \
#	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /headless/.bashrc && \
#	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /root/.bashrc
	
# Run unattended configuration 
#See https://www.ibm.com/support/knowledgecenter/en/SSEP7J_11.0.0/com.ibm.swg.ba.cognos.inst_cr_winux.doc/t_unatt_cnfg.html#unatt_cnfg
COPY cogstartup.xml_configured ${COGNOS_DIR}/configuration/
COPY cogsetup_wait.sh /dockerstartup/
RUN \
	sed -i 's/\r//g' /dockerstartup/cogsetup_wait.sh && \
	chmod uo+x /dockerstartup/*.sh
		
# Cognos UI port
EXPOSE 9300

# Copy desktop shortcuts
COPY Cognos_Config.desktop /headless/Desktop

# Copy Cloudera Impala JDBC drivers
# To get the drivers, refer to https://www.cloudera.com/downloads/connectors/impala/jdbc/2-6-4.html
# Note: If you are not going to use Cloudera Impala drivers, comment out the next line
COPY /media/ImpalaJDBC41.jar ${COGNOS_DIR}/drivers/

# How long to wait for DB2 to come up, default (in minutes)
ENV COGNOS_WAIT_DB2_MINS_DEF	4

# Switch back to regular user
USER 1000

# The below command is used to keep the base xfce up and running, replaced by our startup
#CMD ["-d --wait"]

# Kick-off unattended Cognos configuration
CMD ["/dockerstartup/cogsetup_wait.sh"]