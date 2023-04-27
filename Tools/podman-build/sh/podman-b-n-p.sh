#!/bin/bash

echo "version 5"
echo "Load the latest git hash to TAG env var"
export TAG=$(cat git_hash)

if [ "$ENV" = "prod" ]; then
  echo "Skipping build and push for production environment"
  exit 0
else
  echo "Building container from ${WORKENV}/app/Dockerfile with name ${IMAGE}:ver_${TAG}"
  podman build app/ -t "${IMAGE}:ver_${TAG}"

  echo "Pushing image to external registry ${IMAGE}:ver_${TAG}"
  podman push "${IMAGE}:ver_${TAG}"
fi
