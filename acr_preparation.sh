acr_name=geomicronacr
RESOURCE_GROUP=geo-fms-micron-rg
ACR_SP_App_ID=XXXXXXXXXXXXXXXXXXXXXXXXX
ACR_SP_Passwd=XXXXXXXXXXXXXXXXXXXXXXXXX


az acr create --resource-group $RESOURCE_GROUP --name $acr_name --sku Basic
az acr import --name $acr_name --source klatestacr.azurecr.io/dataapi02:v43 --image fileservice:v06  --username $ACR_SP_App_ID --password $ACR_SP_Passwd
az acr import --name $acr_name --source klatestacr.azurecr.io/scanmanagerv1:v13 --image scanmanager:v06  --username $ACR_SP_App_ID --password $ACR_SP_Passwd
az acr import --name $acr_name --source klatestacr.azurecr.io/newclamav:v4 --image clamav:v06  --username $ACR_SP_App_ID --password $ACR_SP_Passwd
az acr import --name $acr_name --source klatestacr.azurecr.io/filecleanupservice:v3 --image filecleanupservice:06  --username $ACR_SP_App_ID --password $ACR_SP_Passwd

#Print the script execute status
if [ $? -eq 0 ]; then 
	echo "############# ACR Pre-Request Script Executed Successfully #############"
else
	echo "############# ACR Pre-Request Script Executin Failed - Review Error Log #############"
fi
echo "   "
