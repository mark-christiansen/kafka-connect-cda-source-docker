#!/bin/bash

echo "Stopping Kafka environment"
docker compose down

echo "Cleaning up volumes"
rm -rf volumes/s3/billing-center
rm -rf volumes/s3/policy-center
rm -rf volumes/grafana/data
rm -rf volumes/kafka-1/data
rm -rf volumes/prometheus/data
rm -rf volumes/zoo-1/data
rm -rf volumes/zoo-1/logs