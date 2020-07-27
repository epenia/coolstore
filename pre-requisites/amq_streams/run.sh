 #/bin/bash

oc process -f template.yaml --param-file=env | oc create -f -
