!#/bin/bash
echo "Cleaning old files"
rm -rf ${WORKENV}
echo "Clone ${GIT} Repository"
git clone ${GIT} ${WORKENV}
echo "Pring Local Path"
pwd
echo "Show Folder Content" 
ls -l