#!/usr/bin/env bash
set -e

VERSION=1.3.1

userid=$(id -u)

function release_file() {
  os="$(uname -s | awk '{print tolower($0)}')"
  arch="$(uname -m | awk '{print tolower($0)}')"

  case "$arch" in
    "x86_64")
    arch="amd64"
    ;;
    "armv6l" | "armv7l" | "aarch64")
    arch="arm"
    ;;
    *)
      arch=""
  esac

  echo "chisel_${os}_${arch}.gz"
}

if [[ ! ${userid} -eq 0 ]]; then
  echo "script must be run as root"
  exit 1
fi

curl -sSL -o - https://github.com/jpillora/chisel/releases/download/${VERSION}/$(release_file) | gunzip > /usr/local/bin/chisel
chmod a+x /usr/local/bin/chisel

if [[ "$(chisel --help 2>&1 | grep ${VERSION})" == "" ]]; then
  echo "install failed"
  exit 1
fi
