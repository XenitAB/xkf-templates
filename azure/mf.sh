#!/bin/bash


SUFFIX=$(grep SUFFIX=\"tfstate Makefile2)
echo $SUFFIX
sed -i '/SUFFIX=\"tfstate/c\'"$SUFFIX" Makefile
# sed -i "/SUFFIX=\"tfstate/c\${SUFFIX}" Makefile


