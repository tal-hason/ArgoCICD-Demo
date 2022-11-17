# ArgoCICD-Demo

In this repo we have a Project that demoenstrait a full CI and CD pipeline that is utilized with only ArgoCD

## folder Structure

app/ - Contain the application Dockerfile
app/src - the application source files
app/yaml/base - the kustomaized base directory
app/yaml/Overlay/dev - the kustomaized layer of the application
app/yaml/def - the k8s resources that is needed for the project

ci-cd-app/base - the kustomaized base for the ci Argo application
ci-cd-app/Overlays/hw-app - the kustomaized hw-app layer with the ci jobs

Project - an Argo App with HELM chart

Tools/git-clone - the Dockerfile for the git-clone job image
Tools/git-clone/sh - the git clone script
Tools/podman-build - Dockerfile for the podman build(in the job i amusing the officail podman image from quay.io)
Tools/podman-build/sh - the podman build and push script

