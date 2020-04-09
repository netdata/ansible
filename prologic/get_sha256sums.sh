#!/bin/sh

log() {
  printf "%s\n" "$1" >&2
}

error() {
  log "ERROR: $1"
  exit 1
}

get_latest_release() {
  user_repo="$1"
  curl -sL "https://api.github.com/repos/$user_repo/releases" | # Get releases from GitHub api
    jq -r '.[] | .tag_name' |                                   # Extract tag names
    sort -r |                                                   # Sort in reverse order (highest first)
    head -n 1                                                   # Extract the latest released tag name
}

get_release_id() {
  user_repo="$1"
  tag_name="$2"
  curl -sL "https://api.github.com/repos/$user_repo/releases/tags/$tag_name" | # Get releases from GitHub api
    jq -r '.id'                                                                # Extract id
}

get_release_assets() {
  user_repo="$1"
  release_id="$2"
  curl -sL "https://api.github.com/repos/$user_repo/releases/$release_id/assets?page=1&per_page=100" | # Get releases from GitHub api
    jq -r '.[] | .browser_download_url'                                                                # Extract browser_download_url(s)
}

_main() {
  if [ $# -lt 1 ]; then
    log "Usage: %s <user>/<repo>\n" "$(basename "$0")"
    exit 1
  fi

  user_repo="$1"
  shift

  latest_release="$(get_latest_release "$user_repo")"
  log "Latest Release of %s : %s\n" "$user_repo" "$latest_release"

  release_id="$(get_release_id "$user_repo" "$latest_release")"
  log " Release ID of %s : %s\n" "$latest_release" "$release_id"

  get_release_assets "$user_repo" "$release_id"
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  _main "$@"
fi
