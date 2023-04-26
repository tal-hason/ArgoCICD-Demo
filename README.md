# ArgoCICD-Demo

[Live Demo](https://youtu.be/sFNHS1mdglI)

In this repo we have a Project that demonstrate a full CI and CD pipeline that is utilized with only ArgoCD

## Please Fork the Repo and work with your own details

> To start the CI Application on your ArgoCD Instance run the following command to your installed argoCD instance namespace

```Bash
oc apply -f Tools/Deployment-bootstrap.yaml -n {{Argocd-Namespace}}
```

> in order for the update step to successed, Please create a Secret named "gh-token" with a single Key named "TOKEN" that stores your GitHub PAT(Personal Access Token).

```YAML
kind: Secret
apiVersion: v1
metadata:
  name: gh-token
data:
  TOKEN: {{ Your GitHub PAT Here | Base64 }}
type: Opaque
```

> in order for the Build and Push step to successed, Please create a Secret Named "quay.io" with config key named auth.json (podman) and its value your image registry .dockerconfigjson content

```YAML
kind: Secret
apiVersion: v1
metadata:
  name: quay.io
data:
  auth.json: >-
{{ Your .dockerconfigjson file content | Base64 }}
type: Opaque
```

## The main Argo Application is a ConfigMapGeneretor with a base with the related apps

![CI Application](https://github.com/tal-hason/ArgoCICD-Demo/blob/ad6ff3be3097d24bc31ed0ddced0945fc952640d/pictures/ci-Process.png?raw=true)

### the CI Kustomization File

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base
- build-job.yaml
- clone-job.yaml
- Update-image.yaml

configMapGenerator:
- name: ci-cd-details
  envs:
  - https://raw.githubusercontent.com/tal-hason/ArgoCICD-Demo/main/Tools/config
#
# Change destination to promote from dev to prod
#
- name: promote
  literals:
    - destination=prod

generatorOptions:
 disableNameSuffixHash: true
 annotations:
    argocd.argoproj.io/sync-wave: "0"

```

#### Now the CI process support image taging from git Hash from the lasted commit when the ConfigMap "promote" Key "destination" equel "dev"

When the destination equal "prod":

* The build and push job skips builidng a new image.
* The update job get the image tag from the dev depolyment and update the production.
* All the JObs now runs directly from the latest cloned script so every changes to the job script will be updated on the fly! no need to build new images.

## The Hello-world application also build with kustomized layer and is related to the same config

![Hello-World-App](https://github.com/tal-hason/ArgoCICD-Demo/blob/assests/pictures/Hello-world-App.png?raw=true)

### the Hello-world dev env app Kustomization File

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

nameSuffix: -dev

configMapGenerator:
- name: ci-cd-details
  envs:
  - https://raw.githubusercontent.com/tal-hason/ArgoCICD-Demo/main/Tools/config
- name: tag
  literals:
    - TAG=ca3001

images:
- name: quay.io/argocicd/hello-world
  newName: 'quay.io/argocicd/hello-world'
  newTag: ca3001

patchesJSON6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: argocicd
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 1
- target:
    kind: Route
    name: argocicd-dev
  patch: |-
    - op: replace
      path: /spec/to/name
      value: argocicd-dev
```

### the Hello-world prod env app Kustomization File

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

nameSuffix: -prod

configMapGenerator:
- name: ci-cd-details
  envs:
  - https://raw.githubusercontent.com/tal-hason/ArgoCICD-Demo/main/Tools/config
- name: tag
  literals:
    - TAG=ca3001

images:
- name: quay.io/argocicd/hello-world
  newName: 'quay.io/argocicd/hello-world'
  newTag: ca3001

patchesJSON6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: argocicd
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
- target:
    kind: Route
    name: argocicd-prod
  patch: |-
    - op: replace
      path: /spec/to/name
      value: argocicd-prod
```

## In the CI process there is 3 steps

* Step 1, Git Clone, an Image that pull the Application Git, it runs the following script

    ```Bash
    #!/bin/bash
    echo "Cleaning old files"
    rm -Rfv ${WORKENV}/*
    rm -Rfv ${WORKENV}/.*
    echo "Clone ${GIT} Repository"
    git clone https://${GIT} ${WORKENV}
    echo "Show Folder Content" 
    ls -l ${WORKENV}
    echo "Get latest Git Log Hash for the new Tag"
    cd ${WORKENV}
    git log -1 --format="%h" | cut -c1-6 > ${WORKENV}/git_hash
    ```

* Step 2, Build and push the new application image, the new image tag and name are transfered from the config file that is mapped as enviorment varibales, it runs the following script:

    ```bash
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
    ```

* Step 3, Update the Deployment with the new image tag that we build, it runs the follwoing script:

    ```bash
    #!/bin/bash
    
    # Exit script immediately if a command exits with a non-zero status
    set -e
    
    # Set Git User Name & E-mail
    git config --global user.email "$EMAIL"
    git config --global user.name "$NAME"
    
    if [[ "$ENV" == "prod" ]]; then
      echo "Update Production Image from Dev"
    
      # Get the current image from Dev and set it as $TAG
      export TAG=$(yq eval '.images[].newTag' "$WORKENV/app/yaml/Overlay/d
      
      echo "dev deployment is --> ${TAG}"
    
      echo "Update production deployment with the dev tag"
      sed -i "s/newTag:.*/newTag: $TAG/" "$WORKENV/app/yaml/Overlay/$ENV/k
      
      echo "Update ConfigMap with the new build tag"
      sed -i "s/TAG=.*/TAG=$TAG/" "$WORKENV/app/yaml/Overlay/$ENV/kustomiz
    else
      echo "Load the latest git hash to TAG env var"
      TAG=$(cat "$WORKENV/git_hash")
      
      echo "Update deployment with the new build tag"
      sed -i "s/newTag:.*/newTag: $TAG/" "$WORKENV/app/yaml/Overlay/$ENV/k
      
      echo "Update ConfigMap with the new build tag"
      sed -i "s/TAG=.*/TAG=$TAG/" "$WORKENV/app/yaml/Overlay/$ENV/kustomiz
    fi
    
    # Move to the Git folder
    cd "$WORKENV"
    
    echo "Add new change to Git"
    git add "$WORKENV/app/yaml/Overlay/$ENV/kustomization.yaml"
    
    echo "Commit new version"
    git commit -m "$COMMIT"
    
    echo "Push update to Git"
    git push "https://$NAME:$TOKEN@github.com/tal-hason/ArgoCICD-Demo.git"
    ```
