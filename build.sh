#!/bin/sh

# Exit if an error is encountered
set -e

###############################################################
# This script will build the core version of the EAP instance,
# storing the image to jlgrock/jboss-eap.  If you drop extra WARs
# into the install directory, you can create a custom deployment.
# It is suggested that you don't use this script though, as you'll
# want to store this image to something other than jlgrock/jboss-eap.
# For example, you can put webapp.war in there and create an instance
# called my/webapp.
###############################################################

# load the versions
. ./loadenv.sh

FILES_IMAGE_NAME=jlgrock/jboss-eap-fuse-files
IMAGE_NAME=jlgrock/jboss-eap-fuse
IMAGE_VERSION=${JBOSS_EAP}
TMP_IMAGE_NAME="${IMAGE_NAME}-temp"

echo "Processing for ${IMAGE_NAME}:${IMAGE_VERSION}"

# TODO update these file checks so they are more generic
if [ ! -e eap-fuse-files/install-files/fuse-eap-installer-6.2.1.redhat-084.jar ]; then
    echo "Could not find file install-files/fuse-eap-installer-6.2.1.redhat-084.jar"
    echo "Please add the required file first."
    exit 255
fi

if [ ! -e eap-fuse-files/install-files/fuse-integration-eap-installer-1.3.0.redhat-002.jar ]; then
    echo "Could not find file install-files/fuse-integration-eap-installer-1.3.0.redhat-002.jar"
    echo "Please add the required file first."
    exit 255
fi

if [ ! -e eap-fuse-files/install-files/fuse-eap-installer-6.2.1.redhat-090.jar ]; then
    echo "Could not find file install-files/fuse-eap-installer-6.2.1.redhat-090.jar"
    echo "Please add the required file first."
    exit 255
fi

if [ ! -e eap-fuse-files/install-files/jboss-datagrid-7.1.0-eap-modules-library.zip ]; then
    echo "Could not find file install-files/jboss-datagrid-7.1.0-eap-modules-library.zip"
    echo "Please add the required file first."
    exit 255
fi

# Create a temporary image - assuming you do a base image pull yourself
echo "Creating JBoss EAP with Fuse Files Image ..."
docker build -q -t ${TMP_IMAGE_NAME}:${IMAGE_VERSION} eap-fuse-files/

# Start Image and get ID
ID=$(docker run -d --entrypoint /bin/bash ${TMP_IMAGE_NAME}:${IMAGE_VERSION} /bin/bash)
echo "Container ID '$ID' now running"

# Flatten the image (removes AUFS layers) and create a new image
# Note that you lose history/layers and environment variables with this method,
# but it slims down the image significantly.  The known necessary environment
# variables have been added back
FLAT_ID=$(docker export ${ID} | docker import - ${FILES_IMAGE_NAME}:${IMAGE_VERSION})
echo "Created Flattened image with ID: ${FLAT_ID} for ${IMAGE_NAME}:${IMAGE_VERSION}"

# Cleanup
echo "destroying intermediate containers related to $TMP_IMAGE_NAME (all versions)"
docker ps -a | awk '{ print $1,$2 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $1 }' | xargs -I {} docker rm {}
docker images -a | awk '{ print $1, $3 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $2 }' | xargs -I {} docker rmi {}

# Create final image
echo "Creating JBoss EAP with Fuse Image ${IMAGE_NAME}:${IMAGE_VERSION}..."
docker build -q --rm -t ${IMAGE_NAME}:${IMAGE_VERSION} eap-fuse/

if [ $? -eq 0 ]; then
    echo "Container Built"
else
    echo "Error: Unable to Build Container"
fi
