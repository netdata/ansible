# Auto Claiming Agent

## Build (and push) the docker image

### Build

```bash
git clone -b knats-auto-claim https://github.com/knatsakis/netdata

docker build netdata                         \
  --file netdata/packaging/docker/Dockerfile \
  --tag netdata:autoclaimed                  \
  --build-arg CFLAGS="-DACLK_SSL_ALLOW_SELF_SIGNED"
```

### Push to the testing environment

```bash
docker tag netdata:autoclaimed gcr.io/netdata-cloud-testing/netdata:autoclaimed
docker push gcr.io/netdata-cloud-testing/netdata:autoclaimed
```

### Push to the staging environment

```bash
docker tag netdata:autoclaimed gcr.io/netdata-cloud-stg-200202/netdata:autoclaimed
docker push gcr.io/netdata-cloud-stg-200202/netdata:autoclaimed
```

### Run on the testing environment

```bash
helm upgrade                                                     \
  --kube-context <context>                                       \
  --namespace default                                            \
  --install                                                      \
  --atomic --cleanup-on-fail                                     \
  --reset-values                                                 \
  --set image="gcr.io/netdata-cloud-testing/netdata:autoclaimed" \
  --set claim_token=""                                           \
  --set claim_room=""                                            \
  --set aclk_url="https://dev.private.netdata.cloud"             \
  netdata-cloud-agent ./helm
```

### Run on the staging environment

```bash
helm upgrade                                                        \
  --kube-context <context>                                          \
  --namespace default                                               \
  --install                                                         \
  --atomic --cleanup-on-fail                                        \
  --reset-values                                                    \
  --set image="gcr.io/netdata-cloud-stg-200202/netdata:autoclaimed" \
  --set claim_token=""                                              \
  --set claim_room=""                                               \
  --set aclk_url="https://staging.netdata.cloud"                    \
  netdata-cloud-agent ./helm
```

### Run locally

Set appropriate values for `CLAIM_TOKEN`, `CLAIM_ROOM` and `ACLK_URL`, then run:

```bash
docker run          \
  -e CLAIM_TOKEN="" \
  -e CLAIM_ROOM=""  \
  -e ACLK_URL=""    \
  netdata:autoclaimed
```

- For testing, the `ACLK_URL` is https://dev.private.netdata.cloud
- For staging, the `ACLK_URL` is https://staging.netdata.cloud
