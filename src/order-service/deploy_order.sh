#!/bin/bash

oc new-app --docker-image mongo:4.0 --name=order-database

mvn quarkus:add-extension -Dextensions="resteasy-jsonb,mongodb-client"
mvn quarkus:add-extension -Dextensions="kafka"
mvn clean package -DskipTests

#oc new-build registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.5 --binary --name=order -l app=order
#oc start-build order --from-file target/*-runner.jar --follow

#oc new-app order
#oc expose svc/order


oc label dc/order app.openshift.io/runtime=quarkus  --overwrite
oc label dc/order app.kubernetes.io/part-of=order --overwrite && \
oc label dc/order-database app.kubernetes.io/part-of=order app.openshift.io/runtime=mongodb --overwrite && \
oc annotate dc/order app.openshift.io/connects-to=my-cluster,order-database --overwrite && \
oc annotate dc/order app.openshift.io/vcs-ref=ocp-4.4 --overwrite
