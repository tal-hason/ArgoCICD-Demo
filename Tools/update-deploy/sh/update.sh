#!/bin/bash

echo 'Update with the new build tag'
sed -i 's/newTag:.*/newTag: "${TAG}"/' $WORKENV/app/yaml/Overlay/dev/kustomization.yaml

# Set Git User Nmae & E-mail
git config --global user.email $EMAIL
git config --global user.name $NAME

# Move to the Git Folder
cd $WORKENV

echo 'Add new Change to the Git'
git add $WORKENV/app/yaml/Overlay/dev/kustomization.yaml

echo "Commit New Version"
git commit -m "${COMMIT}"

echo "Push Update to Git"
git push https://$NAME:$TOKEN@github.com/tal-hason/ArgoCICD-Demo.git
