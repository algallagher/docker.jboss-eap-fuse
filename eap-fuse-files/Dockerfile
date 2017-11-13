FROM jlgrock/jboss-eap:6.4.6
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV INSTALL_DIR $EAP_PARENT/install-files

RUN mkdir -p $INSTALL_DIR/jdg $EAP_HOME/modules/system/layers/jdg
ADD install-files/ $INSTALL_DIR

WORKDIR $EAP_HOME 
RUN java -jar $INSTALL_DIR/fuse-eap-installer-6.2.1.redhat-084.jar
RUN java -jar $INSTALL_DIR/fuse-integration-eap-installer-1.3.0.redhat-002.jar
RUN java -jar $INSTALL_DIR/fuse-eap-installer-6.2.1.redhat-090.jar
RUN unzip -q $INSTALL_DIR/jboss-datagrid-6.6.0-eap-modules-library.zip \
	&& mv jboss-datagrid-6.6.0-eap-modules-library/modules/* \
		$EAP_HOME/modules/system/layers/jdg \
	&& rm -rf jboss-datagrid-6.6.0-eap-modules-library/ \
	&& echo -n ",jdg" >> $EAP_HOME/modules/layers.conf


RUN rm -rf $INSTALL_DIR
