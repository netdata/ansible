ARG docker_tag=20.10.4
ARG helm_tag=3.5.2
ARG terraform_tag=0.14.7

FROM alpine/helm:${helm_tag} as helm-source
FROM docker:${docker_tag} as static-docker-source
FROM hashicorp/terraform:${terraform_tag} as terraform-source

FROM debian:buster
ARG CLOUD_SDK_VERSION=329.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV CLOUDSDK_PYTHON=python3
ARG K9S_VERSION=v0.24.2
ENV K9S_VERSION=$K9S_VERSION

ARG INSTALL_COMPONENTS
ENV PATH "$PATH:/opt/google-cloud-sdk/bin/"
COPY --from=helm-source /usr/bin/helm /usr/bin/helm
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
COPY --from=terraform-source /bin/terraform /bin/terraform
RUN apt-get update -qqy && apt-get install -qqy \
        curl \
        gcc \
        python3-dev \
        python3-pip \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        wget \
        vim-tiny \
        gnupg && \
    pip3 install -U crcmod && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS kubectl kubectx && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    apt-get clean

RUN git config --system credential.'https://source.developers.google.com'.helper gcloud.sh

RUN wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
    tar -xzpf k9s_Linux_x86_64.tar.gz k9s && \
    mv k9s /bin && \
    chmod 755 /bin/k9s && \
    rm -f k9s_Linux_x86_64.tar.gz
