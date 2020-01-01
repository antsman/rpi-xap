#!/bin/bash

VERSIONS=version.properties

test -n "$1" && (
  echo HAH_VERSION=\"$(docker exec -t $1 cat /etc/xap.d/build | tr -d '\r')\" | tee $VERSIONS

  OS_ID=$(docker exec -t $1 cat /etc/os-release | grep -G ^ID= | awk -F= '{ print $2 }' | tr -d '\r')
  OS_VERSION_ID=$(docker exec -t $1 cat /etc/os-release | grep -G VERSION_ID= | awk -F= '{ print $2 }' | tr -d '"\r')
  echo OS_VERSION=\"${OS_ID}-${OS_VERSION_ID}\" | tee -a $VERSIONS
) || (
  echo Give container name as parameter!
  exit 1
)
