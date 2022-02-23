##Configure variable for resource creation##

RESOURCE_GROUP=geo-fms-micron-rg
fms_storage_acc=geofmsmicronsa
##customer_name=cusA

#Create Resource Group
az group create -n $RESOURCE_GROUP -l westus


#Create Storage account for FMS
az storage account create -n $fms_storage_acc -g $RESOURCE_GROUP -l westus --kind StorageV2 --sku Standard_RAGRS

# Set storage key as variable
storage_acc_key=$(az storage account keys list --resource-group $RESOURCE_GROUP  --account-name $fms_storage_acc --query '[0].value' -o tsv)

# Create Container for Terraform state
az storage container create -n micronin --account-key $storage_acc_key --account-name $fms_storage_acc
az storage container create -n micronout --account-key $storage_acc_key --account-name $fms_storage_acc
az storage container create -n micronklaupload --account-key $storage_acc_key --account-name $fms_storage_acc
az storage container create -n micronkladownload --account-key $storage_acc_key --account-name $fms_storage_acc
az storage container create -n micronkladowninfected --account-key $storage_acc_key --account-name $fms_storage_acc
az storage container create -n micronoutinfected --account-key $storage_acc_key --account-name $fms_storage_acc

# Create Storage Table
az storage table create --name GeoFileInfo --account-key $storage_acc_key --account-name $fms_storage_acc
az storage table create --name GeoFileActivity --account-key $storage_acc_key --account-name $fms_storage_acc

#Install Apllication-insights extension
az extension add --name application-insights

# Create Application Insights 
az monitor app-insights component create --app geofmsmicronai --location westus --kind web -g $RESOURCE_GROUP -o json > appins.json 

instrumentationKey=$(jq -r ".instrumentationKey" appins.json)

#Print the script execute status
if [ $? -eq 0 ]; then
        echo "############# FMS storage account Setup Script Executed Successfully #############"
else
        echo "############# FMS storage account Setup Script Execution Failed - Review Error Log #############"
fi
echo "  " 

echo Storage account name : $fms_storage_acc
echo Storage account key : $storage_acc_key 
echo App Insight InstrumentationKey : $instrumentationKey
