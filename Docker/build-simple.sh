#!/bin/bash

# Simple Build All Script
# Quick script to build all Docker images and save as tar files

set -e

echo "Building all Docker images..."

# Build each service
for dir in broker-mqtt Camera legacy-telnet Sensor-coap Others/*/; do
    if [ -f "$dir/dockerfile" ] || [ -f "$dir/Dockerfile" ]; then
        echo "Building $dir..."
        
        # Create image name
        image_name=$(echo "polytl-$(basename "$dir")" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        
        # Build and save
        docker build --platform linux/amd64 -t "$image_name" "$dir"
        docker save "$image_name" -o "$dir/${image_name}.tar"
        
        echo "Saved: $dir/${image_name}.tar"
    fi
done

echo "All builds complete!"
