#!/usr/bin/zsh

function usage {
    print "This script start docker container whit predefined parameters."
    print "Usage: start_builder.sh <system_type>"
    print
    print "You must specify system type which you want to start e.g. (bionic, centos7 ...)"
}

if [ ${#} -ne 1 ]; then
    usage
    exit 1
fi

OS=$1
DOCKER_IMAGE="buildb-${OS}"

function update_deps_yum {
    docker exec ${DOCKER_IMAGE} sudo yum install -y proto ss7-tools > /dev/null 2>&1
}

function update_deps_apt {
    docker exec ${DOCKER_IMAGE} sudo apt install -y --force-yes proto ss7-tools > /dev/null 2>&1
}

function update_deps_android {
    docker exec ${DOCKER_IMAGE} sudo apt update > /dev/null 2>&1
    docker exec ${DOCKER_IMAGE} sudo apt install -y arm-proto=0.1.18 proto=0.1.18 > /dev/null 2>&1
}

function update_deps {
    case "${OS}" in
        ( "centos"* ) update_deps_yum ;;
        ( "trusty"* | "xenial" | "bionic" ) update_deps_apt ;;
        ( "android" | "arm"* | "cell") update_deps_android ;;
    esac
}

function start_builder {
    docker kill ${DOCKER_IMAGE} > /dev/null 2>&1
    sleep 1
    docker run --rm -dti -v /home/plengarov/:/home/plengarov --name ${DOCKER_IMAGE} ${DOCKER_IMAGE}
}

start_builder
update_deps
