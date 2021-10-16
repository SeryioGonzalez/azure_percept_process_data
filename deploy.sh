#!/bin/bash

source config.sh

az account set -s $subscription_name

#CHECK CONTAINER REPO
az acr repository show -n $registry_name --repository $repository_name &> /dev/null
if [ $? -ne 0 ]
then
    echo "Repo $repository_name does not exist in registry $registry_name. Base version is 0.0.0"
    latest_build_number=0

else
    echo "Repo $repository_name found in registry $registry_name"
    latest_build_number=$(az acr repository show-tags -n $registry_name --repository $repository_name -o tsv | grep $arch | sed "s/-$arch//" | cut -d"." -f3 | sort -n | tail -1 )
fi

#CALCULATE NEXT CONTANER VERSION. THIS WILL BE 0.0.x
next_build_number=$((latest_build_number+1))
next_version_in_tag="0.0.$next_build_number"
echo "Last build is $latest_build_number"
echo "Next version is $next_version_in_tag"

image_url="$registry_url/$repository_name:$next_version_in_tag-$arch"
echo "Updated image URL is $image_url"

#PUSH THE CONTAINER TO THE REPO
echo "Building docker container"
docker build  --rm -f $docker_file -t $image_url $project_path -q > /dev/null
echo "Pushing docker container"
docker push $image_url > /dev/null


#CHECK THE DEPLOYMENT MANIFEST EXIST
if ! [ -e $reference_percept_edge_deployment_file ]
then
    echo "ERROR: IoT Edge Deployment manifest $reference_percept_edge_deployment_file does not exist"
    echo "Go grab one from the portal and store it in $reference_percept_edge_deployment_file"
    exit
fi

#CHECK THE DEPLOYMENT MANIFEST IS JSON VALID
cat  $reference_percept_edge_deployment_file | jq -e . &>/dev/null
if [ $? -ne 0 ]
then
    echo "ERROR: IoT Edge Deployment manifest not a valid json file $reference_percept_edge_deployment_file"
    echo "Go grab one from the portal, but do it well and store it in $reference_percept_edge_deployment_file"
    exit
fi

#UPDATING DEPLOYMENT MANIFEST WITH NEW VERSION
jq --arg image_url $image_url --arg module_name $iot_edge_module_name '.modulesContent."$edgeAgent"."properties.desired".modules."\($module_name)".settings.image = $image_url' $reference_percept_edge_deployment_file > $updated_percept_edge_deployment_file

#UPDATE THE IOT EDGE DEPLOYMENT MANIFEST WITH NEW URI
az iot edge set-modules -d $device_name -n $iot_hub_name --content ./"$updated_percept_edge_deployment_file" > /dev/null
