#!/bin/bash

IMAGE_MASK=mjbright/jup
DOCKERHUB_USER_URL="https://hub.docker.com/r/mjbright"

hostname=$(hostname)
[ ! -d $hostname ] && mkdir $hostname
echo "\$hostname=$hostname"

WORK=$hostname/work

PULL=0
RUN=0
KILL=0
STATUS=0;
BASE_PORT0=891
#BASE_PORT0=10891

PORT_MAPPINGS=$hostname/port_mappings.txt

ROOT=$HOME/z/bin/jupyter/jupyter_trusted_builds
cd $ROOT

################################################################################
# Functions:
die() {
    echo "$0: die- $*" >&2
    exit 1
}

baseport() {
    case $hostname in
        mike1.hpintelco.org)     let BASE_PORT=10000+$BASE_PORT0;;
        pbell)     let BASE_PORT=14000+$BASE_PORT0;;

        MJBRIGHT7) die "No docker-stacks on $hostname";;
        *)         die "No hostname";;
    esac

    #echo "[$hostname] $BASE_PORT"
    #export BASE_PORT
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

build_status() {
    for image in $(docker search $IMAGE_MASK | grep -v ^NAME | awk '{print $1;}'); do
        image=${image#*/}
        echo "lynx -dump $DOCKERHUB_USER_URL/$image/builds"
        lynx -dump $DOCKERHUB_USER_URL/$image/builds |
            perl -ne '
                if (/404/) { $SEEN_404=1; next; }
                if (/Page Not Found/) { die "No such image as <$image>"; }
                if (/Build Code\s+Build Status/) { $INSTATUS=1; next; }
                if ($INSTATUS) {
                    m/^\s+\[\d+\](\w+)\s+(\w+)\s+(.+)/;
                    print "$1, $2, $3\n";
                    $INSTATUS=0;
                };'

    done
}

run() {
    echo; echo "---- Launching images as daemons ...";
    docker images | grep $IMAGE_MASK

    let PORT=$BASE_PORT-1
    echo "BASE_PORT=$BASE_PORT"
    echo "PORT=$PORT"
#exit 0

    [ ! -d $WORK ] && {
        echo "[$PWD] mkdir -p $WORK";
        mkdir -p $WORK;
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
        CMD="docker run $OPTS -v /var/run/docker.sock:/var/run/docker.sock -v ${HOME}:/host.home -v $WORK:/home/jovyan/work -it -p ${PORT}:8888 $image"
        $CMD
        echo "[$PWD] $CMD" > $hostname/.run.${image#*/}

        echo "${PORT}: $image" >&2
    done 2> $PORT_MAPPINGS

    echo "Port mappings:"
    cat $PORT_MAPPINGS
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

baseport

################################################################################
# Args:
while [ ! -z "$1" ];do
    case $1 in
        -s)  STATUS=1;;
        -r)  RUN=1;
             [ "$2" != "" ] && { shift; IMAGE_TO_START=$1; };
             ;;
        -nr) RUN=0;;
        -p)  PULL=1;;
        -np) PULL=0;;
        -k)  KILL=1;;

        -wj) WORK=$HOME/z/bin/jupyter;;

        -w)  shift; WORK=$1;
             [ ! -d $WORK ] && die "No such 'work' directory as <$WORK>";;

        *)   die "Unknown option '$1'";;
    esac
    shift
done


################################################################################
# Main:

[ $KILL   -ne 0 ] && kill
[ $PULL   -ne 0 ] && pull
[ $RUN    -ne 0 ] && run
[ $STATUS -ne 0 ] && build_status


