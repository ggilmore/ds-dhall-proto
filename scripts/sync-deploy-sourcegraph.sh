#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -euxo pipefail

ROOT_DIR="$(pwd)"
UPSTREAM_DIR="${ROOT_DIR}/src/upstream"
RAW_OUTPUT_DIR="${UPSTREAM_DIR}/raw"
STRENGTHENED_OUTPUT_DIR="${UPSTREAM_DIR}/strengthened"

mkdir -p "${RAW_OUTPUT_DIR}"
mkdir -p "${STRENGTHENED_OUTPUT_DIR}"

SCRATCH=$(mktemp -d "$ROOT_DIR/sync-deploy-sourcegraph_XXXXXXX")
cleanup() {
  rm -rf "$SCRATCH"
}
trap cleanup EXIT

CLONE_DIR="${SCRATCH}/deploy-sourcegraph"

git clone https://github.com/sourcegraph/deploy-sourcegraph.git "${CLONE_DIR}"
cd "${CLONE_DIR}"

DEPLOY_SOURCEGRAPH_COMMIT="${DEPLOY_SOURCEGRAPH_COMMIT:-90c2ab042d2ca16c73df4563c7964350387bffc9}"
git checkout "${DEPLOY_SOURCEGRAPH_COMMIT}"

ds-to-dhall --destination "${RAW_OUTPUT_DIR}/resources.dhall" --schema "${RAW_OUTPUT_DIR}/schema.dhall" ./base
ds-to-dhall --strengthenSchema --destination "${STRENGTHENED_OUTPUT_DIR}/resources.dhall" --schema "${STRENGTHENED_OUTPUT_DIR}/schema.dhall" ./base
