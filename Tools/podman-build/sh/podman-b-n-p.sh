#!/bin/bash
echo "Build contianer from  ${WORKENV}/${LOC} with name ${IMAGE}:${TAG}"
podman build app/ -t ${IMAGE}:${TAG}

echo "push image to external registry ${IMAGE}:${TAG}"
podman push ${IMAGE}:${TAG}