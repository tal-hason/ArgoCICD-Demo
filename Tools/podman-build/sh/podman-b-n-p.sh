#!/bin/bash
podman build ${WORKENV}/${LOC} -t ${IMAGE}:${TAG}

podman push ${IMAGE}:${TAG}