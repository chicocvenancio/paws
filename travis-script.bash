#!/bin/bash
set -euo pipefail
# Used by travis to trigger deployments or builds
# Keeping this here rather than make travis.yml too complex

ACTION="${1}"
PUSH=''
if [[ ${ACTION} == 'build' ]]; then
    if [[ ${TRAVIS_PULL_REQUEST} == 'false' ]]; then
        PUSH='--push'
        # Assume we're in master and have secrets!
        docker login -u $DOCKER_USERNAME -p "$DOCKER_PASSWORD" quay.io
    fi

    ./build.py --image-prefix quay.io/wikimedia-paws-beta/ build --commit-range ${TRAVIS_COMMIT_RANGE} ${PUSH}
elif [[ ${ACTION} == 'deploy' ]]; then
    echo 'Deploying...'
    curl \
        --no-buffer \
        --show-error \
        --silent \
        --fail \
        -d crypt-key="${GIT_CRYPT_KEY}" \
        -d release=prod \
        -d commit=${TRAVIS_COMMIT} \
        -d repo=https://github.com/chicocvenancio/paws \
        -H "Authorization: Bearer ${DEPLOY_HOOK_KEY}" \
        https://paws-beta-deploy-hook.wmflabs.org/deploy
fi
