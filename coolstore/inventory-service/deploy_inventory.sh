#!/bin/bash

oc new-app -e POSTGRESQL_USER=inventory \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=inventory openshift/postgresql:10 \
  --name=inventory-database


mvn quarkus:add-extension -Dextensions="jdbc-postgresql"
mvn clean package -DskipTests

oc new-build registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.5 --binary --name=inventory -l app=inventory

oc start-build inventory --from-file target/*-runner.jar --follow


oc new-app inventory -e QUARKUS_PROFILE=prod
oc expose svc/inventory


oc label dc/inventory app.openshift.io/runtime=quarkus  --overwrite && \
oc label dc/inventory app.kubernetes.io/part-of=inventory --overwrite && \
oc label dc/inventory-database app.kubernetes.io/part-of=inventory app.openshift.io/runtime=postgresql --overwrite && \
oc annotate dc/inventory app.openshift.io/connects-to=inventory-database --overwrite && \
oc annotate dc/inventory app.openshift.io/vcs-ref=ocp-4.4 --overwrite

