
# Processing Azure Percept DK inferencing data
In the default set-up of the Azure DK, the camera module inferencing output is directly sent to IoT Hub, as shown in the following image.
![Lab diagram](images/lab_1.jpg "Header Image")

The responsible of this behaviour are the routes on the IoT Edge device defined in the IoT Hub instance serving this DK.

In this lab, we are going to add an IoT Edge module that process this data in the device itself, before sending it over to the cloud, as shown here:
![Lab diagram](images/lab_3.jpg "Header Image")

We are going to use Azure CLI and code a simple module in Python. Certainly other choices are possible, but this are my preferences :)
You also need a docker runtime in your PC. I recommend WSL if you are a Windows user

## Add the configuration of your environment
In your favorite editor of choice, edit the following variables shown empty in config.sh:

![Lab diagram](images/lab_4.jpg "Header Image")

Just to clarify:
- registry_name = The name of your ACR (Azure Container Registry) instance
- device_name = The name of the AzPercept DK in your IoT Hub

## Build the container and push it to ACR for the first time
The script is considering the initial states, when certain items required are missing. The first thing we need is having this module in an ACR instance, so IoT Hub can connect to.
We run the script:
```
./deploy.sh
```
![Lab diagram](images/lab_5.jpg "Header Image")

The script produces a final failure, but this is expected. Now the image is uploaded to our ACR instance:
![Lab diagram](images/lab_6.jpg "Header Image")

## Deploy the container to Azure Percept for the first time
Once the module is running and the routes are properly defined, the module can be updated automatically with the provided script.
![Lab diagram](images/lab_7.jpg "Header Image")

### Add ACR credentials to IoT Edge Configuration
As shown in the previous image, highlighted in red, you need to provide ACR credentials. For this, go to your ACR instance, under **Settings > Access Keys**, Enable **Admin user** and copy the fields **Login server, username and password** to the fields highlighted in red.

