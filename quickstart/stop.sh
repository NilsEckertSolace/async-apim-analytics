#!/usr/bin/env bash

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));

############################################################################################################################
# Settings

dockerProjectName="amax-qs"
dockerComposeFile="$scriptDir/docker-compose.yml"

############################################################################################################################
# Run

echo ">>> Stop containers for API Management Connector and API Management Analytics ..."
docker-compose -p $dockerProjectName -f "$dockerComposeFile" stop
if [[ $? != 0 ]]; then echo ">>> ERROR: docker-compose stop failed"; exit 1; fi
echo ">>> Success"

###
# End
