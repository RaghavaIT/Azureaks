
# Set AKS Cluster Resource Group
RESOURCE_GROUP=geo-fms-micron-rg

# Set AKS Cluster Name 
CLUSTER_NAME=$(az aks list -g $RESOURCE_GROUP --query '[0].name' -o tsv)

# Set Pod Identity Name 
POD_MANAGE_IDENTITY_NAME=geofmsmicronmi

###POD_MANAGE_IDENTITY_NAME=geoqapod01


## Install AZure AD POD Identity
kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

# Set AKS Node Resource Group
AKS_NODE_RESOURCE_GROUP="$(az aks show -g ${RESOURCE_GROUP} -n ${CLUSTER_NAME} --query nodeResourceGroup -otsv)"

#Create Manage Identity for POD 
###az identity create -g ${AKS_NODE_RESOURCE_GROUP} -n ${POD_MANAGE_IDENTITY_NAME} 

# Set Manage Identity Principle Id as a variable 

podidentity_clientid="$(az identity show -g $RESOURCE_GROUP -n ${POD_MANAGE_IDENTITY_NAME} --query principalId -o tsv)"

# Set AppGW ID as variable
appgwid=$(az network application-gateway list --query '[].id' -o tsv)

# Provide the identity Contributor access to your Application Gateway
###az role assignment create --role Contributor --assignee $podidentity_clientid --scope $appgwid

# Set AppGW Resource Group ID as variable
appgwrgId=$(az group show -g $RESOURCE_GROUP --query 'id' -o tsv)

# Provide the identity Reader access to your Application Gateway Resource Group

###az role assignment create --role Reader --assignee $podidentity_clientid --scope $appgwrgId

# Set AppGW name as variable

applicationGatewayName=$(az network application-gateway list --resource-group $RESOURCE_GROUP --query '[].name' -o tsv)

#Set Subscription ID as variable

subscriptionId=$(az account show --query 'id' -o tsv)

#Set Manage Identity Client Id as a variable 

identityClientId=$(az identity show -g $RESOURCE_GROUP -n ${POD_MANAGE_IDENTITY_NAME} --query clientId -o tsv)

#Set Manage Identity Resource Id as a variable 

identityResourceId=$(az identity show -g $RESOURCE_GROUP -n ${POD_MANAGE_IDENTITY_NAME} --query id -o tsv)


#Add application-gateway-kubernetes-ingress helm repo and update

helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/

helm repo update

#Download helm config 
wget https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-helm-config.yaml -O helm-config.yaml

#Update Helm configuration 

sed -i "s#<subscriptionId>#$subscriptionId#g" helm-config.yaml
sed -i "s#<resourceGroupName>#$RESOURCE_GROUP#g" helm-config.yaml
sed -i "s#<applicationGatewayName>#$applicationGatewayName#g" helm-config.yaml
sed -i "s#<identityResourceId>#$identityResourceId#g" helm-config.yaml
sed -i "s#<identityClientId>#$identityClientId#g" helm-config.yaml

# Install AGIC

helm install ingress-azure -f helm-config.yaml application-gateway-kubernetes-ingress/ingress-azure

#Print the script execute status
if [ $? -eq 0 ]; then
        echo "############# Install AGIC Script Executed Successfully #############"
else
        echo "############# Install AGIC Script Execution Failed - Review Error Log #############"
fi
echo "   "

