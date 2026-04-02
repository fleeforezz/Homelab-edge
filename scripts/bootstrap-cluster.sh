#!/bin/bash

kubectl apply -f shared/traefik-middlewares/
kubectl apply -f clusters/cluster-a/apps/homepage/
kubectl apply -f clusters/cluster-b/apps/homepage/