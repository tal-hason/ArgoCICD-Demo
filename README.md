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

Tools 