# Netdata Cloud Tools Docker Image

This is a Dockerfile intended to be used for building a Docker image
containing all the required tooling for managing Netdata cloud.

It includes:

* Google Cloud SDK
* Terraform
* Helm
* kbuectl
* Docker
* kubectx
* k9s

To persist configuration you will need to use a volume mounted on `/root`
in the Docker image, as this is where `kubectl` and `gcloud` will stor
etheir configuration.

Note that this is a rather large image due to the base
image being very big.
