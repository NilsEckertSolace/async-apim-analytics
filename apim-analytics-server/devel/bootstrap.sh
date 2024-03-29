#!/usr/bin/env bash

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));

############################################################################################################################
# Settings

envFile="$scriptDir/.env"
export DOTENV_CONFIG_PATH="$envFile"

toolsDir="$scriptDir/../tools"
resourcesDir="$scriptDir/resources"

dockerProjectName="amax-devel"
dockerComposeFile="$scriptDir/docker-compose.yml"

############################################################################################################################
# Helper

function getenv {
  grep "${1}" "$envFile" | cut -f 2 -d '='
}

function isServerAvailable () {
  curl "${1}" -o /dev/null --silent
}

function waitUntilServerIsAvailable () {
  printf "Wait until server is available "
  while ! isServerAvailable "${1}"; do
    printf "."
    sleep 1
  done
  printf "\r\033[2K"
}

############################################################################################################################
# Run

echo ">>> Create and build containers for API Management Connector ..."
docker-compose -p $dockerProjectName -f "$dockerComposeFile" up -d
if [[ $? != 0 ]]; then echo ">>> ERROR: docker compose up failed"; exit 1; fi
echo ">>> Success"

waitUntilServerIsAvailable "http://localhost:$(getenv AMAX_SERVER_CONNECTOR_PORT)"

echo ">>> Create resources for API Management Connector ..."
"$toolsDir/connector.ts" create "${resourcesDir}/organization1.json"
if [[ $? != 0 ]]; then echo ">>> ERROR: connector.ts create failed"; exit 1; fi
"$toolsDir/connector.ts" create "${resourcesDir}/organization2.json"
if [[ $? != 0 ]]; then echo ">>> ERROR: connector.ts create failed"; exit 1; fi
echo ">>> Success"

###
# End
