#!/bin/bash
echo "Load the latest git hash to TAG env var"
export TAG=$(cat git_hash)

if [ "$ENV" = "prod" ]; then
  echo "Skipping build and push for production environment"
  exit 0
else
  echo "Building container from ${WORKENV}/app/Dockerfile with name ${IMAGE}:${TAG}"
  podman build app/ -t "${IMAGE}:${TAG}"

  echo "Pushing image to external registry ${IMAGE}:${TAG}"
  podman push "${IMAGE}:${TAG}"
fi
