#!/bin/bash

oc new-app jboss/infinispan-server:10.0.0.Beta3 --name=datagrid-service

mvn quarkus:add-extension -Dextensions="openshift"
mvn quarkus:add-extension -Dextensions="kafka"
mvn clean package -DskipTests

oc new-build registry.access.redhat.com/ubi8/openjdk-11 --binary --name=cart -l app=cart
oc start-build cart --from-file target/*-runner.jar --follow

oc new-app cart
oc expose svc/cart


oc label dc/cart app.kubernetes.io/part-of=cart app.openshift.io/runtime=quarkus --overwrite && \
oc label dc/datagrid-service app.kubernetes.io/part-of=cart app.openshift.io/runtime=datagrid --overwrite && \
oc annotate dc/cart app.openshift.io/connects-to=my-cluster,catalog,datagrid-service --overwrite && \
oc annotate dc/cart app.openshift.io/vcs-ref=ocp-4.4 --overwrite
oc label dc/cart app.kubernetes.io/part-of=cart --overwrite
oc annotate dc/cart app.openshift.io/vcs-uri=https://https://github.com/luisarizmendi/coolstore.git --overwrite
