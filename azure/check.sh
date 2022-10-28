#!/bin/bash

templateVersion="1"
echo "Checking version: $templateVersion"
VERSION_FILE="./template.version"

if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    echo "$VERSION_FILE contains version $CURRENT_VERSION"
    if [ "$CURRENT_VERSION" == "$templateVersion" ]; then
        echo "Template version $templateVersion already applied"
        exit 0
    fi 
fi    