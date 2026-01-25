#!/bin/sh
set -e

if [ -z "$GATUS_CONFIG" ]; then    # Injected via ECS before ENTRYPOINT runs
   echo "GATUS_CONFIG not set"
   exit 1
fi 

# Write runtime config to disk before starting the app
mkdir -p /app/config
echo "$GATUS_CONFIG" > /app/config/config.yaml

exec /app/gatus  
