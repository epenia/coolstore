#!/bin/bash


npm install --save-dev nodeshift

npm run nodeshift

oc expose svc/coolstore-ui

oc label dc/coolstore-ui app.openshift.io/runtime=nodejs  --overwrite && \
oc label dc/coolstore-ui app.kubernetes.io/part-of=coolstore --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/connects-to=order-cart,catalog,inventory,order --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/vcs-uri=https://https://github.com/luisarizmendi/coolstore.git --overwrite && \
oc annotate dc/coolstore-ui app.openshift.io/vcs-ref=ocp-4.4 --overwrite
