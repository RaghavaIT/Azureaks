#cd  ~/geo-fms-startup-kit

helm install geo geo

#Print the script execute status
if [ $? -eq 0 ]; then
        echo "############# Geo Application Deployment Completed  Successfully #############"
else
        echo "############# Geo Application Deployment Failed - Review Error Log #############"
fi
echo "   "

