#!/bin/bash

mvn quarkus:add-extension -Dextensions="kafka"

mvn clean package -Pnative -DskipTests

#oc new-build quay.io/quarkus/ubi-quarkus-native-binary-s2i:1.0 --binary --name=payment -l app=payment
#oc start-build payment --from-file target/payment-1.0-SNAPSHOT-runner --follow

oc delete dc/payment




payment_image=$(oc get is | grep payment | awk '{print $2}')

oc create -f - <<EOF
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: payment
spec:
  template:
    metadata:
      name: payment-v1
      annotations:
        # disable istio-proxy injection
        sidecar.istio.io/inject: "false"
    spec:
      containers:
        # Replace Project name userXX-cloudnativeapps with project in which payment is deployed
      - image: $payment_image:1.0-SNAPSHOT
        ports:
          - containerPort: 8080
EOF

sleep 10


oc create -f - <<EOF
apiVersion: sources.knative.dev/v1alpha1
kind: KafkaSource
metadata:
  name: kafka-source
spec:
  bootstrapServers:
   - my-cluster-kafka-bootstrap:9092
  topics:
   - orders
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: payment
EOF

sleep 5


oc label rev/payment-v1 app.openshift.io/runtime=quarkus --overwrite
oc label ksvc/payment app.kubernetes.io/part-of=payment --overwrite
#oc label dc/payment app.kubernetes.io/part-of=payment --overwrite
#oc annotate dc/payment app.openshift.io/connects-to=my-cluster --overwrite && \
#oc annotate dc/payment app.openshift.io/vcs-ref=ocp-4.4 --overwrite
oc annotate ksvc/payment   app.openshift.io/connects-to=my-cluster --overwrite
