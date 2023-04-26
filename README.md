# ArgoCICD-Demo

[Live Demo](https://youtu.be/sFNHS1mdglI)

In this repo we have a Project that demoenstrait a full CI and CD pipeline that is utilized with only ArgoCD

* Please Fork the Repo and work with your own details *

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


> in order for the Build and Push step to successed, Please create a Secret Named "quay.io" with config key named auth.json (podman) and its value your image registry dockercfg json

```YAML
kind: Secret
apiVersion: v1
metadata:
  name: quay.io
data:
  auth.json: >-
ewogICJhdXRocyI6IHsKICAgICJxdWF5LmlvIjogewogICAgICAiYXV0aCI6ICJZWEpuYjJOcFkyUXJZM0psWVhSMWNtVTZTalV6VWpFMlVsTklSMDQ0V0RsT1RVdFJPRlZLVlU1TldrTkRPVUZKUlVsR1dWbFFNRWcxTmxReU1GYzFNRlpJV1VNek5WZERXalF4VEVjd00wNUxTdz09IiwKICAgICAgImVtYWlsIjogIiIKICAgIH0KICB9Cn0=
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

generatorOptions:
 disableNameSuffixHash: true
 annotations:
    argocd.argoproj.io/sync-wave: "0"
```

## The Hello-world application also build with kustomized layer and is related to the same config

![Hello-World-App](https://github.com/tal-hason/ArgoCICD-Demo/blob/assests/pictures/Hello-world-App.png?raw=true)

### the Hello-world app Kustomization File

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

configMapGenerator:
- name: ci-cd-details
  envs:
  - https://raw.githubusercontent.com/tal-hason/ArgoCICD-Demo/main/Tools/config

images:
- name: quay.io/argocicd/hello-world
  newName: 'quay.io/argocicd/hello-world'
  newTag: v1.20

patchesJSON6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: argocicd
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 2
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
    ```

* Step 2, Build and push the new application image, the new image tag and name are transfered from the config file that is mapped as enviorment varibales, it runs the following script:

    ```YAML
    #!/bin/bash
    echo "Build contianer from  ${WORKENV}/${LOC} with name ${IMAGE}:${TAG}"
    podman build app/ -t ${IMAGE}:${TAG}

    echo "push image to external registry ${IMAGE}:${TAG}"
    podman push ${IMAGE}:${TAG}
    ```

* Step 3, Update the Deployment with the new image tag that we build, it runs the follwoing script:

    ```YAML
    #!/bin/bash

    echo 'Update with the new build tag'
    sed -i 's/newTag:.*/newTag: '${TAG}'/' $WORKENV/app/yaml/Overlay/dev/kustomization.yaml
    
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
    ```
