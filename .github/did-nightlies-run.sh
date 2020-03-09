#!/bin/sh

threshold="${1:-172800}"

printf "Checking last published Docker images ... "
last_modified="$(curl -ssL https://hub.docker.com/v2/repositories/netdata/netdata/tags/latest | jq -r '.last_updated')"
last_modified_since="$(($(date +%s) - $(date -d "${last_modified}" +%s)))"
if [ -n "${DEBUG}" ]; then
  printf "\n"
  printf "  Last Modified: %s\n" "${last_modified}"
  printf "  Last Modified: %ds ago\n" "${last_modified_since}"
fi
if [ "${last_modified_since}" -gt "${threshold}" ]; then
  printf "ERR\n"
  exit 1
else
  printf "OK\n"
fi

printf "Checking last published GCS sources ... "
last_modified="$(curl -sSL -I https://storage.googleapis.com/netdata-nightlies/sha256sums.txt | grep -i last-modified | sed -e 's/last-modified: //')"
last_modified_since="$(($(date +%s) - $(date -d "${last_modified}" +%s)))"
if [ -n "${DEBUG}" ]; then
  printf "\n"
  printf "  Last Modified: %s\n" "${last_modified}"
  printf "  Last Modified: %ds ago\n" "${last_modified_since}"
fi
if [ "${last_modified_since}" -gt "${threshold}" ]; then
  printf "ERR\n"
  exit 1
else
  printf "OK\n"
fi

for version in xenial bionic eoan; do
  printf "Checking last published PackageCloud Ubuntu %s package ... " "${version}"
  last_modified="$(curl -sSL https://packagecloud.io/netdata/netdata-edge/ubuntu/dists/"${version}"/Release | grep -o -E '^Date\:.*' | sed -e 's/Date: //')"
  last_modified_since="$(($(date +%s) - $(date -d "${last_modified}" +%s)))"
  if [ -n "${DEBUG}" ]; then
    printf "\n"
    printf "  Last Modified: %s\n" "${last_modified}"
    printf "  Last Modified: %ds ago\n" "${last_modified_since}"
  fi
  if [ "${last_modified_since}" -gt "${threshold}" ]; then
    printf "ERR\n"
    exit 1
  else
    printf "OK\n"
  fi
done

for version in jessie stretch buster; do
  printf "Checking last published PackageCloud Debian %s package ... " "${version}"
  last_modified="$(curl -sSL https://packagecloud.io/netdata/netdata-edge/debian/dists/"${version}"/Release | grep -o -E '^Date\:.*' | sed -e 's/Date: //')"
  last_modified_since="$(($(date +%s) - $(date -d "${last_modified}" +%s)))"
  if [ -n "${DEBUG}" ]; then
    printf "\n"
    printf "  Last Modified: %s\n" "${last_modified}"
    printf "  Last Modified: %ds ago\n" "${last_modified_since}"
  fi
  if [ "${last_modified_since}" -gt "${threshold}" ]; then
    printf "ERR\n"
    exit 1
  else
    printf "OK\n"
  fi
done
