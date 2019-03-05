#!/usr/bin/with-contenv /bin/bash
 
set -e

source /srv/docker-container/utils/config-defaults.sh

echo "Installing osgi plugins for Tomcat ${TOMCAT_VERSION}"
if [[ -d /plugins/osgi ]]; then
    echo "Found $(find /plugins/osgi/ -mindepth 1 -maxdepth 1 -name *.jar | wc -l) plugins"
    
    ## TODO: chown files here, via tmpdir
    cp /plugins/osgi/*.jar /data/shared/felix/load/
fi

echo "Installing static plugins with JAVA_HOME=${JAVA_HOME}"
if [[ -d /plugins/static ]]; then
    echo "Found $(find /plugins/static/ -mindepth 1 -maxdepth 1 -type d | wc -l) plugins"
    mv /srv/plugins/common.xml /tmp/plugins-common.xml
    mv /srv/plugins/plugins.xml /tmp/plugins-plugins.xml
    cp -a /plugins/static/* /srv/plugins/
    mv /tmp/plugins-common.xml /srv/plugins/common.xml 
    mv /tmp/plugins-plugins.xml /srv/plugins/plugins.xml 

    cd /srv && ./bin/deploy-plugins.sh || exit 1
fi
