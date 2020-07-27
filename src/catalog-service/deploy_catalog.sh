#!/bin/bash

oc new-app -e POSTGRESQL_USER=catalog \
    -e POSTGRESQL_PASSWORD=mysecretpassword \
    -e POSTGRESQL_DATABASE=catalog \
    openshift/postgresql:10 \
    --name=catalog-database

mvn clean package spring-boot:repackage -DskipTests

oc new-build registry.access.redhat.com/ubi8/openjdk-11 --binary --name=catalog -l app=catalog
oc start-build catalog --from-file=target/catalog-1.0.0-SNAPSHOT.jar --follow


oc new-app catalog -e JAVA_OPTS_APPEND='-Dspring.profiles.active=openshift'
oc expose service catalog


oc label dc/catalog app.kubernetes.io/part-of=catalog app.openshift.io/runtime=spring --overwrite && \
oc label dc/catalog-database app.kubernetes.io/part-of=catalog app.openshift.io/runtime=postgresql --overwrite && \
oc annotate dc/catalog app.openshift.io/connects-to=inventory,catalog-database --overwrite && \
oc annotate dc/catalog app.openshift.io/vcs-uri=https://github.com/luisarizmendi/coolstore.git --overwrite && \
oc annotate dc/catalog app.openshift.io/vcs-ref=ocp-4.4 --overwrite
