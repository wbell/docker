#!/usr/bin/with-contenv /bin/bash

set -e

source /srv/docker-container/utils/discovery-include.sh
source /srv/docker-container/utils/config-defaults.sh


if [[ -z "${PROVIDER_HAZELCAST_DNSNAMES}" ]]; then

    echo "PROVIDER_HAZELCAST_GROUPNAME=${PROVIDER_HAZELCAST_GROUPNAME}" >>/srv/docker-container/config/settings.ini
    echo "PROVIDER_HAZELCAST_PORT=${PROVIDER_HAZELCAST_PORT}" >>/srv/docker-container/config/settings.ini

    exit 0
fi

sleep ${PROVIDER_HAZELCAST_SVC_DELAY_MIN}

count=${PROVIDER_HAZELCAST_SVC_DELAY_MAX}
hz_members=()

echo "Trying discovery for ${count} seconds"
IFS=',' read -ra hz_candidate_names <<< "${PROVIDER_HAZELCAST_DNSNAMES}" && unset IFS

while [[ $count -ge ${PROVIDER_HAZELCAST_SVC_DELAY_MIN} || ${#hz_candidate_names[@]} -ne ${#hz_members[@]} ]]; do

    if [[ ${#hz_candidate_names[@]} -gt 0 ]]; then
        echo "Testing service candidates..."
        for hz_candidate_name in "${hz_candidate_names[@]}"; do
            echo -n "  ${hz_candidate_name}: "
            if dockerize -wait "tcp://${hz_candidate_name}:${PROVIDER_HAZELCAST_PORT}" -timeout ${PROVIDER_HAZELCAST_SVC_DELAY_STEP}s true 2&>1 >/dev/null; then
                [[ $(inArray "${hz_candidate_name}" "${hz_members[@]}" ) == false ]] && hz_members+=(${hz_candidate_name})
                echo "live"
            else
                echo "not live"
            fi
            sleep ${PROVIDER_HAZELCAST_SVC_DELAY_STEP}
            (( count-=${PROVIDER_HAZELCAST_SVC_DELAY_STEP} )) || :
        done
    else
        echo "Error parsing PROVIDER_HAZELCAST_DNSNAMES (${PROVIDER_HAZELCAST_DNSNAMES})"
        exit 1
    fi
done


if [[ ${#hz_members[@]} -gt 0 ]]; then
    echo "PROVIDER_HAZELCAST_DISCOVERY_HOSTS=$(join , ${hz_members[@]})" >>/srv/docker-container/config/settings.ini
else
    echo "Unable to find any live Hazelcast cluster members after ${PROVIDER_HAZELCAST_SVC_DELAY_MAX} seconds"
    exit 1
fi

echo "PROVIDER_HAZELCAST_GROUPNAME=${PROVIDER_HAZELCAST_GROUPNAME}" >>/srv/docker-container/config/settings.ini
echo "PROVIDER_HAZELCAST_PORT=${PROVIDER_HAZELCAST_PORT}" >>/srv/docker-container/config/settings.ini

 
