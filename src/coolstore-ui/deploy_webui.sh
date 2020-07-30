#!/bin/bash


npm install --save-dev nodeshift

npm run nodeshift

oc expose svc/coolstore-ui

oc label dc/coolstore-ui app.openshift.io/runtime=nodejs  --overwrite && \
oc label dc/coolstore-ui app.kubernetes.io/part-of=coolstore --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/connects-to=order-cart,catalog,inventory,order --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/vcs-uri=https://https://github.com/luisarizmendi/coolstore.git --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/vcs-ref=ocp-4.4 --overwrite



oc create -f - <<EOF
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: coolstore-ui-cpu-autoscale
spec:
  scaleTargetRef:
    apiVersion: apps.openshift.io/v1
    kind: DeploymentConfig
    name: coolstore-ui
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageValue: 300m
EOF
