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
  --set replicas=1                                               \
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
  --set replicas=1                                                  \
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

## Get values for `CLAIM_TOKEN`, `CLAIM_ROOM`, `ACLK_URL`

To get the claim token and claim room visit your space, click the `Add` button
and copy the values from the claiming command shown. E.g., from:

```bash
sudo netdata-claim.sh -token=AKORwHQzoRzeKseRDypY4hjzlPw_EOTw7m1fZfg_eExV0gWohHlmQ21TQ9nxu-EXwn4Iqw7Ox0DWW4QMUAd5T-Bh9Y1hOcTPuU0-S-K9qQOiVAUHQ0Xs1-M6X5qQ2c4lhPJIfJk -rooms=34a639b6-5bd8-4ad4-b4bc-af54ee6e2008 -url=https://staging.netdata.cloud
```

you get:

```
CLAIM_TOKEN="AKORwHQzoRzeKseRDypY4hjzlPw_EOTw7m1fZfg_eExV0gWohHlmQ21TQ9nxu-EXwn4Iqw7Ox0DWW4QMUAd5T-Bh9Y1hOcTPuU0-S-K9qQOiVAUHQ0Xs1-M6X5qQ2c4lhPJIfJk"
CLAIM_ROOM="34a639b6-5bd8-4ad4-b4bc-af54ee6e2008"
ACLK_URL="https://staging.netdata.cloud"
```
