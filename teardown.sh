#!/bin/bash

echo "Stopping Kafka environment"
docker compose down

echo "Cleaning up volumes"
find volumes/s3/billing-center -mindepth 1 -delete
find volumes/s3/policy-center -mindepth 1 -delete
find volumes/grafana -mindepth 1 -delete
find volumes/kafka-1 -mindepth 1 -delete
find volumes/postgres -mindepth 1 -delete
find volumes/prometheus -mindepth 1 -delete
find volumes/zoo-1 -mindepth 1 -delete