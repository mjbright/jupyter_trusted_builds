#!/bin/bash

BUILD_OPTS=""

die() {
    echo "$0: die - $*" >&2
    exit 1
}

build_image() {
    BASE_IMAGE=$1
    IMAGE=$1

    echo; echo "Creating Dockerfile for image <$IMAGE>"

    get_image_name $BASE_IMAGE
    IMAGE_NAME=$__RESULT
    DOCKERFILE=Dockerfile.${IMAGE_NAME}

    BASE_IMAGE=$BASE_IMAGE perl -pe ' s/BASE_IMAGE/$ENV{BASE_IMAGE}/; ' Dockerfile.template > $DOCKERFILE
    ls -altr Dockerfile.template $DOCKERFILE
    #sed "s/BASE_IMAGE/$BASE_IMAGE/" Dockerfile.template > $DOCKERFILE

    DOCKERFILE=${DOCKERFILE%%*/} # Relative path
    mv $DOCKERFILE $IMAGE_NAME/Dockerfile || die "Failed to create Dockerfile"
}

get_image_name() {
    __RESULT=${1#*/}
    __RESULT=${__RESULT%:*}

    [ "$__RESULT" == "docker-demo-images" ] &&
        __RESULT=demo

    echo "get_image_name($1) ==> <$__RESULT>"
}

BASE_IMAGES="
    jupyter/minimal-notebook
    jupyter/all-spark-notebook
    jupyter/pyspark-notebook
    jupyter/scipy-notebook
    jupyter/r-notebook
    jupyter/datascience-notebook
    jupyter/docker-demo-images
"
##? jupyter/notebook

build_all() {

    for BASE_IMAGE in $BASE_IMAGES; do
        echo $BASE_IMAGE
        echo
        get_image_name $BASE_IMAGE
        IMAGE=$USER/jupyter_${__RESULT}

        build_image $BASE_IMAGE $IMAGE
    done
}


build_all

exit 0
################################################################################

> docker search notebook | grep ^jupyter/
jupyter/all-spark-notebook   Jupyter Notebook Python, Scala, R, Spark, ...   7                    [OK]
##? jupyter/notebook                                                         5                    [OK]
jupyter/pyspark-notebook     Jupyter Notebook Python, Spark, Mesos Stac...   4                    [OK]
jupyter/scipy-notebook       Jupyter Notebook Scientific Python Stack f...   4                    [OK]
jupyter/r-notebook           Jupyter Notebook R Stack https://github.co...   1                    [OK]
jupyter/datascience-notebook Jupyter Notebook R, Python, Julia Data Sci...   1                    [OK]
jupyter/minimal-notebook     Minimal Jupyter Notebook image for https:/...   0                    [OK]

