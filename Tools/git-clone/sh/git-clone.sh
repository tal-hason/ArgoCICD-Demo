#!/bin/bash
echo "Cleaning old files"
rm -Rfv ${WORKENV}/*
rm -Rfv ${WORKENV}/.*
echo "Clone ${GIT} Repository"
git clone ${GIT} ${WORKENV}
echo "Show Folder Content" 
ls -l ${WORKENV}
