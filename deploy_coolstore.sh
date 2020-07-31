#!/bin/bash

cd src


########################
# Inventory Service
#######################
cd inventory-service
chmod +x deploy_inventory.sh
./deploy_inventory.sh

oc get dc inventory
if [ $? -ne 0 ];
then
    ./deploy_inventory.sh
fi

cd ..


########################
# Catalog Service
#######################
cd catalog-service
chmod +x deploy_catalog.sh
./deploy_catalog.sh

oc get dc catalog
if [ $? -ne 0 ];
then
    ./deploy_catalog.sh
fi

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

oc get dc cart
if [ $? -ne 0 ];
then
    ./deploy_cart.sh
fi

cd ..


########################
# Order Service
#######################
cd order-service
chmod +x deploy_order.sh
./deploy_order.sh

oc get dc order
if [ $? -ne 0 ];
then
    ./deploy_order.sh
fi

cd ..





########################
# WEB-UI Service
#######################
cd coolstore-ui
chmod +x deploy_webui.sh
./deploy_webui.sh

oc get dc coolstore-ui
if [ $? -ne 0 ];
then
    ./deploy_webui.sh
fi

cd ..






########################
# Payment Service
#######################
cd payment-service
chmod +x deploy_payment.sh
./deploy_payment.sh

sleep 15

oc get deployment payment-v1-deployment
if [ $? -ne 0 ];
then
    ./deploy_payment.sh
fi

cd ..




cd ..
