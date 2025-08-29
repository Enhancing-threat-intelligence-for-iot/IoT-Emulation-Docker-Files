#!/bin/bash

# Load All Docker Images Script
# This script loads all tar files back into Docker

echo "Loading Docker images from tar files..."

# Find all tar files and load them
find . -name "polytl-*.tar" -type f | while read tar_file; do
    echo "Loading: $tar_file"
    docker load -i "$tar_file"
done

echo "All images loaded!"
echo ""
echo "Available images:"
docker images | grep polytl-
