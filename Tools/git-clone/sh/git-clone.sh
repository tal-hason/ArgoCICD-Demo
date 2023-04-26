#!/bin/bash
echo "Cleaning old files"
rm -Rfv ${WORKENV}/*
rm -Rfv ${WORKENV}/.*
echo "Clone ${GIT} Repository"
git clone https://${GIT} ${WORKENV}
echo "Show Folder Content" 
ls -l ${WORKENV}
echo "Get latest Git Log Hash for the new Tag"
git log -1 --format="%h" | cut -c1-6 > ${WORKENV}/git_hash
