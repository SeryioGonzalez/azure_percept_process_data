#!/bin/bash

#YOU NEED TO UPDATE
subscription_name=""
registry_name=""
iot_hub_name=""
device_name=""

#DO NOT TOUCH
repository_name="dataparser"
project_path="module/$repository_name"
docker_file="$project_path/Dockerfile.arm64v8"
registry_url="$registry_name.azurecr.io"
arch="arm64v8"

iot_edge_module_name=$repository_name

reference_percept_edge_deployment_file="percept.reference.deployment.json"
updated_percept_edge_deployment_file="percept.updated.deployment.json"

if [ $subscription_name"ffffff" = "ffffff" ] 
then
    echo "ERROR: Initialize the subscription_name variable in config"
    exit
fi
if [ $registry_name"ffffff" = "ffffff" ] 
then
    echo "ERROR: Initialize the registry_name variable in config"
    exit
fi
if [ $iot_hub_name"ffffff" = "ffffff" ] 
then
    echo "ERROR: Initialize the iot_hub_name variable in config"
    exit
fi
if [ $device_name"ffffff" = "ffffff" ] 
then
    echo "ERROR: Initialize the device_name variable in config"
    exit
fi
