# Set AKS Cluster Resource Group
RESOURCE_GROUP=geo-fms-micron-rg

CLUSTER_NAME=geofms-micron-aks

# Set AKS Cluster Name 
#CLUSTER_NAME=$(az aks list -g $RESOURCE_GROUP --query '[0].name' -o tsv)

# Set ACR Name
acr_name=$(az acr list -g $RESOURCE_GROUP --query '[0].name' -o tsv)

#Get Kubernetes configuration 
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP

#Attach ACR with AKS 
az aks update -n $CLUSTER_NAME -g $RESOURCE_GROUP --attach-acr $acr_name

# Print Status Message
if [ $? -eq 0 ]; then
        echo "############# AKS Configuration Script Executed Successfully #############"
else
        echo "############# AKS Configuration Script Execution Failed - Review Error Log #############"
fi
echo "   "

