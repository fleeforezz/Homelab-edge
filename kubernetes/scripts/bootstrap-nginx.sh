#!/bin/bash

docker run -d --name nginx-lb \
  -p 443:443 \
  -v $(pwd)/global-lb/nginx:/etc/nginx \
  nginx:alpine
