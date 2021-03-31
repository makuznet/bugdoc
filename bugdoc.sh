#!/bin/bash

# This script checks the status of the container and desides whether to start or restart it.

if [ "$( sudo docker container inspect -f '{{.State.Status}}' bugdoc )" == "running" ]; then 
    sudo docker restart bugdoc; 
else 
    sudo docker run -it --rm -d -p 80:80 --name bugdoc bugdoc;
fi