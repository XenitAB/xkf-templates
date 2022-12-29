#!/bin/bash

LATEST_TAG=$(git describe --abbrev=0 --tags)
echo "Latest template tag: $LATEST_TAG"
git checkout $LATEST_TAG -b latest


git ls-files *.tf
