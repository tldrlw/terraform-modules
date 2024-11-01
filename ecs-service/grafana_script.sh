#!/bin/bash

# Set variables
S3_BUCKET="tldrlw-ecs-config-files"
S3_FILE="grafana-datasources.yaml"
TARGET_DIR="/etc/grafana/provisioning/datasources"

# Pull the data sources YAML file from S3
echo "Pulling the data source configuration from S3..."
aws s3 cp "s3://${S3_BUCKET}/${S3_FILE}" "${TARGET_DIR}/"

if [ $? -eq 0 ]; then
  echo "File copied successfully to ${TARGET_DIR}"
else
  echo "Error: Failed to copy file from S3"
  exit 1
fi

# Restart the Grafana service
echo "Restarting Grafana..."
/run.sh

# The /run.sh script will start the Grafana service
