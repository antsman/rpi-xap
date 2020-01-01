#!/bin/bash

VERSIONS=version.properties

test -n "$1" && (
  echo HAH_VERSION=\"$(docker exec -t $1 cat /etc/xap.d/build | tr -d '\r')\" | tee $VERSIONS
  # docker exec -t $1 cat /etc/*version*
  OS_ID=$(docker exec -t $1 cat /etc/os-release | grep -G ^ID= | awk -F= '{ print $2 }' | tr -d '\r')
  OS_VERSION_ID=$(docker exec -t $1 cat /etc/os-release | grep -G VERSION_ID= | awk -F= '{ print $2 }' | tr -d '"\r')
  echo OS_VERSION=\"${OS_ID}-${OS_VERSION_ID}\" | tee -a $VERSIONS
  # echo JENKINS_VERSION=\"$(docker exec -t $1 cat /data/war/META-INF/MANIFEST.MF | grep Jenkins-Version | awk '{ print $2 }' | tr -d '\r')\" | tee $VERSIONS
  # echo JAVA_VERSION=\"$(docker exec -t $1 java -version | grep version | awk -F\" '{ print $2 }')\" | tee -a $VERSIONS
  # echo DOCKER_VERSION=\"$(docker exec -t $1 docker --version | grep version | awk '{ print $3 }' | tr -d ',')\" | tee -a $VERSIONS
) || (
  echo Give container name as parameter!
  exit 1
)
