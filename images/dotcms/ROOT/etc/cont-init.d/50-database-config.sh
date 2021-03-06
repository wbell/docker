#!/usr/bin/with-contenv /bin/bash

set -e

source /srv/docker-container/utils/config-defaults.sh


[[ -z "${PROVIDER_DB_DNSNAME}" ]] && PROVIDER_DB_DRIVER="H2"

case "$PROVIDER_DB_DRIVER" in 

    H2)
        : ${PROVIDER_DB_DBNAME:="h2_dotcms_data"}
        ;;

    POSTGRES)
        : ${PROVIDER_DB_DBNAME:="dotcms"}
        [[ -z "$PROVIDER_DB_PORT" ]] && PROVIDER_DB_PORT="5432"
        ;;

    MYSQL)
        : ${PROVIDER_DB_DBNAME:="dotcms"}
        [[ -z "$PROVIDER_DB_PORT" ]] && PROVIDER_DB_PORT="3306"
        ;;

    ORACLE)
        : ${PROVIDER_DB_DBNAME:="XE"}
        [[ -z "$PROVIDER_DB_PORT" ]] && PROVIDER_DB_PORT="1521"
        ;;

    MSSQL)
        : ${PROVIDER_DB_DBNAME:="dotcms"}
        [[ -z "$PROVIDER_DB_PORT" ]] && PROVIDER_DB_PORT="1433"
        ;;

    *)
        echo "Invalid DB driver specified!!"
        exit 1

esac


touch /srv/DB_CONNECT_TEST
[[ "$PROVIDER_DB_DRIVER" != "H2" ]] && echo "${PROVIDER_DB_DNSNAME}:${PROVIDER_DB_PORT}" >/srv/DB_CONNECT_TEST
chmod 400 /srv/DB_CONNECT_TEST

echo "PROVIDER_DB_DRIVER=${PROVIDER_DB_DRIVER}" >>/srv/docker-container/config/settings.ini
[[ -n "$PROVIDER_DB_URL" ]] && echo "PROVIDER_DB_URL=${PROVIDER_DB_URL}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_DBNAME=${PROVIDER_DB_DBNAME}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_DNSNAME=${PROVIDER_DB_DNSNAME}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_PORT=${PROVIDER_DB_PORT}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_USERNAME=${PROVIDER_DB_USERNAME}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_PASSWORD=${PROVIDER_DB_PASSWORD}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_DB_MAXCONNS=${PROVIDER_DB_MAXCONNS}" >>/srv/docker-container/config/settings.ini




