#!/bin/bash



########################
# Workspaces
#######################
cd workspaces
chmod +x run.sh
./run.sh
cd ..



########################
# Service Mesh
#######################
cd service-mesh
chmod +x run.sh
./run.sh
cd ..


########################
# Knative
#######################
cd knative
chmod +x run.sh
./run.sh
cd ..


########################
# Knative Kafka
#######################
cd knative_kafka
chmod +x run.sh
./run.sh
cd ..


########################
# AMQ
#######################
cd amq_streams
chmod +x run.sh
./run.sh
cd ..
