#!/bin/bash

set -e

build_source=$1
build_id=$2
echo "Build source: $build_source"
echo "Build id: $build_id"

build_target_dir=/build/cms
mkdir -p "${build_target_dir}"

get_by_url() {
    build_download_dir=/build/download
    mkdir -p ${build_download_dir}

    echo "Fetching build: $1"
    wget --quiet -O "${build_download_dir}/dotcms.tgz" "$1"
    tar xzf "${build_download_dir}/dotcms.tgz" -C "${build_target_dir}"
    # We should have some verification here, but we have no source of truth yet
}

build_by_commit() {
    mkdir -p /build/src && cd /build/src

    echo "Building from source commit: $1"

    git clone https://github.com/dotCMS/core.git core && cd core
    git reset --hard "$1"

    cd dotCMS && ./gradlew createDist
    build_tarball=$(realpath $(find ../dist-output/ -type f -name dotcms*.tar.gz ))

    tar xzf "${build_tarball}" -C "${build_target_dir}"
}

set_tomcat_dir() {
    TOMCAT_VERSION=$(find /srv/dotserver/ -type d -name tomcat-* | grep -oP "(?<=tomcat-)[0-9]{1}\.[0-9]{1}\.[0-9]+$" | head -n 1)
    [[ -z "${TOMCAT_VERSION}" ]] && echo "ERROR: Unable to determine Tomcat version" && exit 1
    echo ${TOMCAT_VERSION} >/srv/TOMCAT_VERSION
}

case "${build_source}" in 

    "TARBALL_URL" )

        get_by_url "${build_id}"
        ;;

    "RELEASE" )

        get_by_url "https://old.dotcms.com/physical_downloads/release_builds/dotcms_${build_id}.tar.gz"
        ;;

    "NIGHTLY" )

        echo "ERROR: Not implemented"
        exit 1
        ;;

    "COMMIT" | "TAG" )

        build_by_commit "${build_id}"
        ;;

    *) 
        echo "Invalid option"
        exit 1
        ;;
esac

mv ${build_target_dir}/* /srv/

set_tomcat_dir


