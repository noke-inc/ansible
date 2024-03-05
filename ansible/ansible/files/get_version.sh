#!/usr/bin/env bash
FIND_TAG=${1:-""}
docker ps -f name=$FIND_TAG --format '{{.Image}}' | sed "s/^.*://"
