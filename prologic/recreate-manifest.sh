#!/usr/bin/env bash

TAG="${1}"

if [ -z "${TAG}" ]; then
  echo >&2 "Usage: $(basename "${0}") <tag>"
  exit 1
fi

docker manifest create \
  netdata/netdata:"${TAG}" \
  netdata/netdata:"${TAG}"-i386 \
  netdata/netdata:"${TAG}"-armhf \
  netdata/netdata:"${TAG}"-aarch64 \
  netdata/netdata:"${TAG}"-amd64

docker manifest annotate \
  netdata/netdata:"${TAG}" \
  netdata/netdata:"${TAG}"-amd64 \
  --os linux --arch amd64

docker manifest annotate \
  netdata/netdata:"${TAG}" \
  netdata/netdata:"${TAG}"-i386 \
  --os linux --arch 386

docker manifest annotate \
  netdata/netdata:"${TAG}" \
  netdata/netdata:"${TAG}"-armhf \
  --os linux --arch arm

docker manifest annotate \
  netdata/netdata:"${TAG}" \
  netdata/netdata:"${TAG}"-aarch64 \
  --os linux --arch arm64

docker manifest push netdata/netdata:"${TAG}"
