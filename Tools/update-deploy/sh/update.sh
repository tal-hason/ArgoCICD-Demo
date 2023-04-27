#!/bin/bash

echo "version 14"
# Set Git User Name & E-mail
git config --global user.email "$EMAIL"
git config --global user.name "$NAME"

if [[ "$ENV" == "prod" ]]; then
  echo "Update Production Image from Dev"

  # Get the current image from Dev and set it as $TAG
  export TAG=$(yq eval '.images[].newTag' "$WORKENV/app/yaml/Overlay/dev/kustomization.yaml")
  
  echo "dev deployment is --> "${TAG}""

  echo "Update production deployment with the dev tag"
  sed -i "s/newTag:.*/newTag: "${TAG}"/" "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"
  
  echo "Update ConfigMap with the new build tag"
  sed -i "s/TAG=.*/TAG="${TAG}"/" "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"

  echo "Cleanup"
  rm -f $WORKENV/git_hash
else
  echo "Load the latest git hash to TAG env var"
  TAG=$(cat "$WORKENV/git_hash")

  echo "dev deployment is --> "ver_${TAG}""

  echo "Update deployment with the new build tag"
  sed -i "s/newTag:.*/newTag: "ver_${TAG}"/" "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"
  
  echo "Update ConfigMap with the new build tag"
  sed -i "s/TAG=.*/TAG="ver_${TAG}"/" "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"

  echo "Cleanup"
  rm -f $WORKENV/git_hash
fi

# Move to the Git folder
cd "$WORKENV"

echo "Add new change to Git"
git add "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"

echo "Commit new version"
git commit -m "$COMMIT"

echo "Push update to Git"
git push "https://$NAME:$TOKEN@github.com/tal-hason/ArgoCICD-Demo.git"
