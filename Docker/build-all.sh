#!/bin/bash

# Build All Docker Images Script
# This script builds all Docker images and saves them as tar files

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_status "Starting Docker build process..."
print_status "Working directory: $SCRIPT_DIR"

# Define all directories that contain Dockerfiles
DOCKER_DIRS=(
    "broker-mqtt"
    "Camera"
    "legacy-telnet"
    "Sensor-coap"
    "Others/DNS"
    "Others/Modbus"
    "Others/NTP"
    "Others/RTSP"
    "Others/SNMP"
    "Others/SSDP-UPnP"
    "Others/syslog collector"
    "Others/WebSocket"
)

# Build counter
BUILT_COUNT=0
FAILED_COUNT=0
TOTAL_COUNT=${#DOCKER_DIRS[@]}

print_status "Found $TOTAL_COUNT Docker projects to build"
echo ""

# Function to build a single Docker image
build_docker_image() {
    local dir="$1"
    local image_name="$2"
    local tar_name="$3"
    
    print_status "Building: $dir -> $image_name"
    
    if [ ! -f "$dir/dockerfile" ] && [ ! -f "$dir/Dockerfile" ]; then
        print_error "No dockerfile found in $dir"
        return 1
    fi
    
    # Build the Docker image
    if docker build --platform linux/amd64 -t "$image_name" "$dir"; then
        print_success "Built image: $image_name"
        
        # Save to tar file
        print_status "Saving to: $dir/$tar_name"
        if docker save "$image_name" -o "$dir/$tar_name"; then
            print_success "Saved: $dir/$tar_name"
            
            # Show file size
            local size=$(du -h "$dir/$tar_name" | cut -f1)
            print_status "File size: $size"
            
            return 0
        else
            print_error "Failed to save $image_name to tar"
            return 1
        fi
    else
        print_error "Failed to build $image_name"
        return 1
    fi
}

# Build each Docker image
for dir in "${DOCKER_DIRS[@]}"; do
    echo "----------------------------------------"
    
    # Create image name (replace special characters)
    image_name=$(echo "polytl-${dir}" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    tar_name="${image_name}.tar"
    
    if build_docker_image "$dir" "$image_name" "$tar_name"; then
        ((BUILT_COUNT++))
    else
        ((FAILED_COUNT++))
    fi
    
    echo ""
done

echo "========================================"
print_status "Build Summary:"
print_success "Successfully built: $BUILT_COUNT/$TOTAL_COUNT"
if [ $FAILED_COUNT -gt 0 ]; then
    print_error "Failed builds: $FAILED_COUNT/$TOTAL_COUNT"
fi

# List all created tar files
echo ""
print_status "Created tar files:"
find . -name "*.tar" -type f -exec ls -lh {} \; | while read line; do
    echo "  $line"
done

# Optional: Create a combined archive with all tar files
read -p "Do you want to create a combined archive with all tar files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Creating combined archive: docker-images-all.tar.gz"
    tar -czf docker-images-all.tar.gz */polytl-*.tar
    print_success "Combined archive created: docker-images-all.tar.gz"
    ls -lh docker-images-all.tar.gz
fi

print_success "Build process completed!"
