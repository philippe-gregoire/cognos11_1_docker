# Modified from nutsllc\vnc-centos-gnome

FROM centos:centos6
MAINTAINER Nuts Project, LLC <dev@nutsproject.jp>

ENV ROOT_PASSWD=centos

ENV VNC_USER_ID=toybox \
	VNC_USER_PW=passw0rd
	
# Install base and tools ( except "X Window System" "fonts" )
RUN yum update -y && yum groupinstall -y \
        "Desktop" \
        "Japanese Support" \
    && yum install -y \
        epel-release \
        sudo \
        nano gedit \
		openssh openssh-server openssh-clients \
		rsync \
		unzip \
        python-setuptools \
    && yum clean all && rm -rf /tmp/* \
    && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel \
    && chmod 0440 /etc/sudoers.d/wheel

# Supervisor
RUN easy_install supervisor \
	&& mkdir -p /var/log/supervisor \
	&& mkdir -p /etc/supervisord.d \
    && { \
        echo '[supervisord]'; \
        echo 'nodaemon=true'; \
        echo 'logfile=/var/log/supervisor/supervisord.log'; \
        echo 'logfile_maxbytes=1MB'; \
        echo 'logfile_backups=1'; \
        echo 'loglevel=warn'; \
        echo 'pidfile=/var/run/supervisord.pid'; \
        echo '[include]'; \
        echo 'files = /etc/supervisord.d/*.conf'; \
    } > /etc/supervisord.conf

# VNC & XRDP Servers & Autostart services
# tigervnc, tigervnc-server, tigervnc-server-module, xrdp, xinitd
RUN yum update -y \
	&& yum install -y \
        tigervnc-server \
        xrdp \
        xinetd \
		firefox \
	&& yum clean all && rm -rf /tmp/* \
	&& chkconfig vncserver on 3456 \
    && { \
        echo 'VNCSERVERS="0:root 1:$VNC_USER_ID"'; \
        echo 'VNCSERVERARGS[0]="-geometry 1280x960"'; \
        echo 'VNCSERVERARGS[1]="-geometry 1280x960"'; \
    } >> /etc/sysconfig/vncservers \
	&& chkconfig xrdp on 3456 \
	&& chmod -v +x /etc/init.d/xrdp \
	&& chmod -v +x /etc/xrdp/startwm.sh \
	&& echo "gnome-session --session=gnome" > ~/.xsession \
    && { \
        echo '[program:xrdp]'; \
        echo 'command=/etc/init.d/xrdp restart'; \
        echo 'stderr_logfile=/var/log/supervisor/xrdp-error.log'; \
        echo 'stdout_logfile=/var/log/supervisor/xrdp.log'; \
    } > /etc/supervisord.d/xrdp.conf \
    && { \
        echo '[program:vncserver]'; \
        echo 'command=/etc/init.d/vncserver restart'; \
        echo 'stderr_logfile=/var/log/supervisor/vncserver-error.log'; \
        echo 'stdout_logfile=/var/log/supervisor/vncserver.log'; \
    } > /etc/supervisord.d/vnc.conf

# Create User
RUN su root sh -c "yes $ROOT_PASSWD | vncpasswd" \
    && echo "root:$ROOT_PASSWD" | chpasswd \
	&& useradd -g wheel $VNC_USER_ID \
	&& su $VNC_USER_ID sh -c "yes $VNC_USER_PW | vncpasswd" \
    && echo "$VNC_USER_ID:$VNC_USER_PW" | chpasswd

# GNOME Settings for all users
RUN gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool  --set /apps/nautilus/preferences/always_use_browser true \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool --set /apps/gnome-screensaver/idle_activation_enabled false \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool --set /apps/gnome-screensaver/lock_enabled false \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type int --set /apps/metacity/general/num_workspaces 1 \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type=string --set /apps/gnome_settings_daemon/keybindings/screensaver ' ' \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type=string --set /apps/gnome_settings_daemon/keybindings/power ' ' \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool --set /apps/panel/global/disable_log_out true \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type int --set /apps/gnome-power-manager/timeout/sleep_computer_ac '0' \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type int --set /apps/gnome-power-manager/timeout/sleep_display_ac '0' \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type int --set /apps/gnome-screensaver/power_management_delay '0' \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool --set /desktop/gnome/remote_access/enabled true \
	&& gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	    --type bool --set /desktop/gnome/remote_access/prompt_enabled false

# VNC root and $VNC_USER_ID port, RDP port
EXPOSE 5900 5901 3389
		
# Copy optional installers
COPY /installer/ /installer/
		
#######################################################################################################
# Cognos setup
# Based on RHEL Dockerfile from dnastaci@us.ibm.com

# Cognos settings
ENV COGNOS_BASE_DIR /opt/ibm/cognos
ENV COGNOS_DIR      ${COGNOS_BASE_DIR}/analytics

ENV COGNOS_USER     cognosusr

ENV COGNOS_MEDIA_DIR	/installer/cognos

ARG COGNOS_PROPERTIES=cognosca_reponse.properties
ARG COGNOS_HOST=cognos11srv

# IBM Cognos Analytics Installer 2.0 Linux x86 Multilingual (CNV5CML)
ARG COGNOS_INSTALLER=ca_installer_linuxi38664_2.0.bin

# IBM Cognos Analytics Server 11.1.1 Linux x86 Multilingual (CNV5BML) or (CNZ14ML)
ARG COGNOS_SERVER_IMAGE=ca_server_linuxi38664_11.1.1.zip

# IBM Cognos Analytics Samples 11.0 Linux x86-64 Multilingual (CN8AFML)
ARG COGNOS_SAMPLES=ca_smpl_lnxi38664_11.0.0.15121603.bin
		
# Cognos Prepreq (See https://www.ibm.com/support/knowledgecenter/en/SS5R93_5.3.0/com.ibm.spectrum.sc.doc/ins_cognos_analytics_Linux_single.html)
#glibc-2.12-1.166.el6 or later (both i686 and x86_64 packages)
#libstdc++-4.4.7-16.el6 or later (both i686 and x86_64 packages)
#nspr-4.9.2-1.el6 or later (both i686 and x86_64 packages)
#nss-3.14.0.0-12.el6 or later (both i686 and x86_64 packages)
#openmotif-2.3.3-5.el6 or later (both i686 and x86_64 packages)
RUN yum install -y \
        glibc.x86_64 glibc.i686 \
        libstdc++.x86_64 libstdc++.i686 \
		nspr.x86_64 nspr.i686 \
		nss.x86_64 nss.i686 \
		openmotif.x86_64 openmotif.i686 \
	&& yum clean all && rm -rf /tmp/*

#
# Install other dependencies
#
# "which is required for Cognos installation
# "glibc.i686" is required for Cognos installation
# "tigervnc-server xorg-x11-twm xorg-x11-server-utils xterm" are required for cogconfig.sh in XTerminal mode
# "nc" is required by cognos-setup.sh
#
RUN echo "Installing X11" && \
	yum install -y \
	which \
	libstdc++ libstdc++.i686 \
	libX11 libX11.i686 \
	tigervnc-server xorg-x11-twm xorg-x11-server-utils xterm \
	&& yum clean all && rm -rf /tmp/*
	
# For the record, re: https://www.ibm.com/support/knowledgecenter/SSEP7J_11.0.0/com.ibm.swg.ba.cognos.inst_cr_winux.doc/c_inst_ulimitsettingsonunixandlinuxoperatingsystems.html
RUN \
	ulimit -f -t -u -m -n -s -v && \
	echo "Current hostname: `hostname`"
	
# Copy Cognos installer files into the container's filesystem
COPY /media/$COGNOS_INSTALLER ${COGNOS_MEDIA_DIR}/
COPY /media/$COGNOS_SERVER_IMAGE ${COGNOS_MEDIA_DIR}/
COPY /media/$COGNOS_SAMPLES $ENV ${COGNOS_MEDIA_DIR}/

# Copy properties
COPY ${COGNOS_PROPERTIES} ${COGNOS_MEDIA_DIR}
	
# Setup Cognos user and run installer
RUN \
	groupadd -f -g 1000 ${COGNOS_USER} && \
	useradd -u 1000 -g 1000 ${COGNOS_USER} -m && \
	mkdir -p "${COGNOS_DIR}" && \
	chown -R ${COGNOS_USER}:${COGNOS_USER} "${COGNOS_BASE_DIR}" && \
	chmod -R uo+x "${COGNOS_MEDIA_DIR}/${COGNOS_INSTALLER}"

# Run installer
RUN \
	echo "Running cognos silent installer" && \
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
RUN \
	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /home/${COGNOS_USER}/.bashrc && \
	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /home/${VNC_USER_ID}/.bashrc && \
	echo export JAVA_HOME=${COGNOS_DIR}/jre >> /root/.bashrc
		
# Cognos UI port
EXPOSE 9300

########################################################################################
# Final setup stages
COPY docker-entrypoint.sh /entrypoint.sh
# Make sure we're using Linux line endings when built from Windows
RUN sed -i 's/\r//g' entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord"]