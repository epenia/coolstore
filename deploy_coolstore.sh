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






##############
# Config ISTIO
##################################################3


my_project=$(oc project | awk -F \" '{print $2}')

my_appsdomain=$(oc get route  | grep coolstore-ui | awk '{print $2}' | awk -F coolstore-ui-$my_project '{print $2}')


## delete routes
#for i in inventory catalog cart order coolstore-ui
#do
# oc delete route $i
#done





oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: coolstore-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "coolstore-ui-${my_project}${my_appsdomain}"
    - "inventory-${my_project}${my_appsdomain}"
    - "catalog-${my_project}${my_appsdomain}"
    - "cart-${my_project}${my_appsdomain}"
    - "order-${my_project}${my_appsdomain}"
EOF









oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: coolstore-ui-vs
spec:
  hosts:
  - "coolstore-ui-${my_project}${my_appsdomain}"
  gateways:
  - coolstore-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: coolstore-ui
        port:
          number: 8080
EOF


oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: coolstore-inventory-vs
spec:
  hosts:
  - "inventory-${my_project}${my_appsdomain}"
  gateways:
  - coolstore-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: inventory
        port:
          number: 8080
EOF


oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: coolstore-catalog-vs
spec:
  hosts:
  - "catalog-${my_project}${my_appsdomain}"
  gateways:
  - coolstore-gateway
  http:
  - match:
    - uri:
        prefix: /api/products
    route:
    - destination:
        host: catalog
        port:
          number: 8080
EOF



oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: coolstore-cart-vs
spec:
  hosts:
  - "cart-${my_project}${my_appsdomain}"
  gateways:
  - coolstore-gateway
  http:
  - match:
    - uri:
        prefix: /api/cart
    route:
    - destination:
        host: cart
        port:
          number: 8080
EOF


oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: coolstore-order-vs
spec:
  hosts:
  - "order-${my_project}${my_appsdomain}"
  gateways:
  - coolstore-gateway
  http:
  - match:
    - uri:
        prefix: /api/orders
    route:
    - destination:
        host: order
        port:
          number: 8080
EOF











##############
# INJECTING ISTIO SIDECAR
##################################################3

for i in inventory catalog cart order coolstore-ui
do
 oc rollout pause dc/$i
 oc patch dc/$i -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}'
 oc patch dc/$i -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'
 oc patch dc/$i -p '{"metadata":{"labels":{"version":"v1"}}}'
 oc rollout resume dc/$i
 oc rollout latest dc/$i
done





echo ""
echo ""
echo "Connect to http://coolstore$my_appsdomain"
echo ""
