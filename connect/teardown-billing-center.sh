#!/bin/bash

ENV="dev"
SOURCE_TYPE="billing"
CONNECT_SERVER_URL="http://localhost:8083"

curl -k --request DELETE ${CONNECT_SERVER_URL}/connectors/${ENV}-cda-${SOURCE_TYPE}
#curl -k --request DELETE ${CONNECT_SERVER_URL}/connectors/${ENV}-aurora-${SOURCE_TYPE}