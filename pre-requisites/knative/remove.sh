 #/bin/bash

 oc process -f template3.yaml --param-file=env3 | oc delete -f -

oc process -f template2.yaml --param-file=env2 | oc delete -f -

oc process -f template.yaml --param-file=env | oc delete -f -
