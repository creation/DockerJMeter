#!/bin/bash

# This builds the images and needs to only be run once.

docker build -t jmeterbase -f jmeterbase/Dockerfile . \
  && docker build -t jmetermaster -f jmetermaster/Dockerfile . \
  && docker build -t jmeterslave -f jmeterslave/Dockerfile . \
