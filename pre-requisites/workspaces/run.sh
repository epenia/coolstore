 #/bin/bash

oc process -f template.yaml --param-file=env | oc create -f -

RESOURCE="checlusters"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done

NAMESPACE=$(grep NAME env2 | awk -F \" '{print $2}')
oc process -f template2.yaml --param-file=env2 | oc -n $NAMESPACE create -f -





#sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#sudo yum install -y jq



#NAMESPACE_CRW=$(cat env | grep NAMESPACE | awk -F \" '{print $2}')


#HOSTNAME=$(oc get route --all-namespaces | grep code | awk '{print $3}')
#HOSTNAME_KEYCLOAK=$(oc get route --all-namespaces | grep keycloak | awk '{print $3}')


## Wait for che to be up
#echo "Waiting for Che to come up..."
#while [ 1 ]; do
#  STAT=$(curl -s -w '%{http_code}' -o /dev/null http://$HOSTNAME/dashboard/)
#  if [ "$STAT" = 200 ] ; then
#    break
#  fi
#  echo -n .
#  sleep 10
#done



## get keycloak admin password
#KEYCLOAK_USER="$(oc set env deployment/keycloak --list -n $NAMESPACE_CRW|grep SSO_ADMIN_USERNAME | cut -d= -f2)"
#KEYCLOAK_PASSWORD="$(oc set env deployment/keycloak --list -n $NAMESPACE_CRW|grep SSO_ADMIN_PASSWORD | cut -d= -f2)"

## Wait for che to be back up
#echo "Waiting for keycloak to come up..."
#while [ 1 ]; do
#  STAT=$(curl -s -w '%{http_code}' -o /dev/null http://$HOSTNAME_KEYCLOAK/auth/)
#  if [ "$STAT" = 200 ] ; then
#    break
#  fi
#  echo -n .
#  sleep 10
#done

#echo "Keycloak credentials: $KEYCLOAK_USER / $KEYCLOAK_PASSWORD"
