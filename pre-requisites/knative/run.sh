 #/bin/bash


oc process -f template.yaml --param-file=env | oc create -n openshift-operators -f -

RESOURCE="knativeservings"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done





echo "Configure Serving"
oc process -f template2.yaml --param-file=env2 | oc create -f -


echo "Configure Eventing"
oc process -f template3.yaml --param-file=env3 | oc create -f -
