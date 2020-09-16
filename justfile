all: check freeze format lint build

build: render-ci-pipeline

render-ci-pipeline:
    ./scripts/render-ci-pipeline.sh

format: format-dhall prettier format-shfmt

lint: lint-dhall shellcheck

freeze: freeze-dhall

check: check-dhall

prettier:
    yarn run prettier

build-k8s:
    dhall-to-yaml --explain --file=src/k8s/pipeline.dhall

build-docker-compose:
    dhall-to-yaml --explain --file=src/docker-compose/frontend-pipeline.dhall

check-dhall:
    ./scripts/dhall-check.sh

format-dhall:
    ./scripts/dhall-format.sh

freeze-dhall:
    ./scripts/dhall-freeze.sh

lint-dhall:
    ./scripts/dhall-lint.sh

shellcheck:
    ./scripts/shellcheck.sh

sync-upstream:
    ./scripts/sync-deploy-sourcegraph.sh

format-shfmt:
    shfmt -w .

install:
    just install-asdf
    just install-yarn

install-yarn:
    yarn

install-asdf:
    asdf install
