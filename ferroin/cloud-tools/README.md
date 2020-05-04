# Netdata Cloud Tools Docker Image

This is a Dockerfile intended to be used for building a Docker image
containing all the required tooling for managing Netdata cloud.

It includes:

* Google Cloud SDK 290.0.1
* All of the Google Cloud SDK components provided by Google
* Terraform 0.12.21
* Helm 3.1.3
* kbuectl 1.10.2 (provided by the Google Cloud SDK base image)
* Docker 17.12.0-ce (provided by the Google Cloud SDK base image)
* kubectx current

The Google Cloud SDK, Terraform, and Helm versions can be customized
at build time using the `gcloud_tag`,`terraform_tag`, and `helm_tag`
build arguments.

Authentication setup is unchanged from the [Google Cloud SDK base
image](https://hub.docker.com/r/google/cloud-sdk).

Note that this is a rather large image (almost 2GB) due to the base
image being very big.
