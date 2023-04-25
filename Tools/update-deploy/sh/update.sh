#!/bin/bash

# Update with the new build tag
sed -i 's/newTag:.*/newTag: '${TAG}'/' $WORKENV/app/yaml/Overlay/dev/kustomization.yaml

git config --global user.email $EMAIL
git config --global user.name $NAME

cd $WORKENV

git add $WORKENV/app/yaml/Overlay/dev/kustomization.yaml

git commit -m '${COMMIT}'

git push https://$NAME:$TOKEN@github.com/tal-hason/ArgoCICD-Demo.git
