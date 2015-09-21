#!/bin/bash

IMAGE_MASK=mjbright/jup


PULL=0
RUN=0
KILL=0
BASE_PORT=10891

################################################################################
# Functions:
die() {
    echo "$0: die- $*" >&2
    exit 1
}

pull() {
    echo; echo "---- Pulling images ...";
    docker images | grep $IMAGE_MASK
    #df .

    for image in $(docker search $IMAGE_MASK | grep -v ^NAME | awk '{print $1;}'); do
        echo "docker pull $image"
        docker pull $image 2>/dev/null  | grep Status
        #df .
    done;
    docker images | grep $IMAGE_MASK
}

run() {
    echo; echo "---- Launching images as daemons ...";
    docker images | grep $IMAGE_MASK

    let PORT=$BASE_PORT-1

    [ ! -d work ] && {
        echo "[$PWD] mkdir work";
        mkdir work;
    }

    for image in $(docker search $IMAGE_MASK | grep -v ^NAME | awk '{print $1;}'); do
        let PORT=PORT+1

        [ ! -z "$IMAGE_TO_START" ] && {
            echo $image | grep $IMAGE_TO_START || {
                echo "Skipping image <$image> (matching <<$IMAGE_TO_START>>)";
                continue
            }
        }

        echo "docker run $image"
        OPTS="--rm"
        OPTS="-d"
        #docker run $OPTS -v /var/run/docker.sock:/var/run/docker.sock -v ${HOME}:/host.home -v ${HOME}/work:/home/jovyan/work -it -p ${PORT}:8888 $image
        docker run $OPTS -v /var/run/docker.sock:/var/run/docker.sock -v ${HOME}:/host.home -v ./work:/home/jovyan/work -it -p ${PORT}:8888 $image

        echo "${PORT}: $image" >&2
    done 2> port_mappings.txt

    echo "Port mappings:"
    cat port_mappings.txt
}

kill() {
    echo; echo "---- Stopping running containers matching images [$IMAGE_MASK] ...";
    #die "TODO"
    RUNNING_IDS=$(docker ps | grep $IMAGE_MASK | awk ' { print$1; }')

    for ID in $RUNNING_IDS; do
       echo "docker stop $ID"
       docker stop $ID
    done
}

IMAGE_TO_START=""

################################################################################
# Args:
while [ ! -z "$1" ];do
    case $1 in
        -r)  RUN=1;
             [ "$2" != "" ] && { shift; IMAGE_TO_START=$1; };
             ;;
        -nr) RUN=0;;
        -p)  PULL=1;;
        -np) PULL=0;;
        -k)  KILL=1;;

        *)   die "Unknown option '$1'";;
    esac
    shift
done


################################################################################
# Main:

[ $KILL -eq 1 ] && kill
[ $PULL -eq 1 ] && pull
[ $RUN  -eq 1 ] && run





