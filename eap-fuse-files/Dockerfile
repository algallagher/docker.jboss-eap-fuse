FROM jlgrock/jboss-eap:7.2.0
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME ${EAP_PARENT}/jboss-eap
ENV INSTALL_DIR ${EAP_PARENT}/install-files

RUN mkdir -p ${INSTALL_DIR}/jdg ${EAP_HOME}/modules/system/layers/jdg
ADD install-files/ ${INSTALL_DIR}

WORKDIR ${EAP_HOME}
RUN java -jar ${INSTALL_DIR}/fuse-eap-installer-7.5.0.jar
RUN /usr/bin/unzip -q ${INSTALL_DIR}/jboss-datagrid-7.3.0-1-eap-modules.zip \
	&& mv jboss-datagrid-7.3.0-eap-modules/modules/* \
		${EAP_HOME}/modules/system/layers/jdg \
	&& rm -rf jboss-datagrid-7.3.0-eap-modules/ \
	&& sed -i -e '$s/$/,jdg/' ${EAP_HOME}/modules/layers.conf

RUN rm -rf ${INSTALL_DIR}
