#!/bin/bash

echo "Create Billing Center manifest at \"volumes/s3/billing-center/manifest.json\""
mkdir volumes/s3/billing-center
cat > volumes/s3/billing-center/manifest.json <<EOF
{
}
EOF

echo "Create Policy Center manifest at \"volumes/s3/policy-center/manifest.json\""
mkdir volumes/s3/policy-center
cat > volumes/s3/policy-center/manifest.json <<EOF
{
}
EOF

echo "Crete volumes"
mkdir volumes/grafana
mkdir volumes/kafka-1
mkdir volumes/postgres
mkdir volumes/prometheus
mkdir volumes/zoo-1

echo "Starting Kafka environment"
docker compose up -d