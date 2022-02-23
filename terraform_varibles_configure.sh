#Configure variable for resource creation

#RESOURCE_GROUP=<< Resource group Name>>
RESOURCE_GROUP=geo-fms-micron-rg
#terra_storage_acc=klageoqaterra01
terra_storage_acc=geofmsmicronterasa
#aks_sp_name=<<SP name >>
aks_sp_name=geo-fms-micron-aks


#Create Storage account
az storage account create -n $terra_storage_acc -g $RESOURCE_GROUP -l westus --kind StorageV2 --sku Standard_RAGRS

# Set storage key as variable 
storage_acc_key1=$(az storage account keys list --resource-group $RESOURCE_GROUP  --account-name $terra_storage_acc --query '[0].value' -o tsv)

# Create Container for Terraform state
az storage container create -n tfstate --account-key $storage_acc_key1 --account-name $terra_storage_acc

#Create Service Principle for AKS 
az ad sp create-for-rbac --name $aks_sp_name --skip-assignment -o json > auth1.json
appId=$(jq -r ".appId" auth1.json)
password=$(jq -r ".password" auth1.json)
objectId=$(az ad sp show --id $appId --query "objectId" -o tsv)

#Print the script execute status
if [ $? -eq 0 ]; then
        echo "############# Terraform pre-request Script Executed Successfully #############"
else
        echo "############# Terraform pre-request Script Execution Failed - Review Error Log #############"
fi
echo "   "

#Print the vaule of SP values
echo Name: $aks_sp_name
echo ID: $appId
echo Password: $password
echo ObjectId: $objectId
