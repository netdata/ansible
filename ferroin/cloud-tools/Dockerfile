ARG terraform_tag=0.12.21
ARG helm_tag=3.1.3
ARG gcloud_tag=290.0.1

FROM hashicorp/terraform:${terraform_tag} as terraform-source

FROM alpine/helm:${helm_tag} as helm-source

FROM google/cloud-sdk:${gcloud_tag}

COPY --from=terraform-source /bin/terraform /bin/terraform

COPY --from=helm-source /usr/bin/helm /usr/bin/helm

RUN apt-get update && \
    apt-get install kubectx && \
    apt-get clean
