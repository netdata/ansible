#!/bin/sh

certbot --work-dir . --config-dir ./configs --logs-dir ./logs -d '*.internal.netdata.cloud' --manual --preferred-challenges dns certonly
