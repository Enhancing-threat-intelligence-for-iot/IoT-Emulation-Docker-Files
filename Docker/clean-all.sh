#!/bin/bash

# Clean All Script
# Removes all built images and tar files

echo "Cleaning up Docker images and tar files..."

# Remove tar files
echo "Removing tar files..."
find . -name "polytl-*.tar" -type f -delete
find . -name "docker-images-all.tar.gz" -type f -delete

# Remove Docker images
echo "Removing Docker images..."
docker images | grep polytl- | awk '{print $3}' | xargs -r docker rmi -f

echo "Cleanup complete!"
