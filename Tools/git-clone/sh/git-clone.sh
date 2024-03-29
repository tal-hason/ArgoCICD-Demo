#!/bin/bash

echo "version 8"

echo "Cleaning old files"
rm -Rfv ${WORKENV}/*
rm -Rfv ${WORKENV}/.*
echo "Clone ${GIT} Repository"
git config --global --add safe.directory /workspace/output
git clone https://${GIT} ${WORKENV}
echo "Show Folder Content" 
ls -l ${WORKENV}
echo "Get latest Git Log Hash for the new Tag"
cd ${WORKENV}
git log -1 --format="%h" | cut -c1-6 > ${WORKENV}/git_hash
