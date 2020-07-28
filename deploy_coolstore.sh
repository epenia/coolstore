#!/bin/bash

cd src


########################
# Inventory Service
#######################
cd inventory-service
chmod +x deploy_inventory.sh
./deploy_inventory.sh
cd ..


########################
# Catalog Service
#######################
cd catalog-service
chmod +x deploy_catalog.sh
./deploy_catalog.sh
cd ..





##### KAFKA ########################

oc create -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    listeners:
      plain:
        authentiation:
          type: scram-sha-512
      tls:
        authentiation:
          type: tls
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator:
      reconciliationIntervalSeconds: 90
    userOperator:
      reconciliationIntervalSeconds: 120
EOF




oc create -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: orders
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 10
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF


oc create -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: payments
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 10
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF


################################################




########################
# Cart Service
#######################
cd cart-service
chmod +x deploy_cart.sh
./deploy_cart.sh
cd ..


########################
# Order Service
#######################
cd order-service
chmod +x deploy_order.sh
./deploy_order.sh
cd ..





########################
# WEB-UI Service
#######################
cd coolstore-ui
chmod +x deploy_webui.sh
./deploy_webui.sh
cd ..






########################
# Payment Service
#######################
cd payment-service
chmod +x deploy_payment.sh
./deploy_payment.sh
cd ..




cd ..
