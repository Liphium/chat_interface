#!/bin/bash

# Check if the entitlements file exists in the current directory
if [ ! -f ./default.entitlements ]; then
    echo "Error: default.entitlements not found in the current directory."
    exit 1
fi

# Check that we are in the correct directory by verifying pubspec.yaml exists in ../../../
if [ ! -f ../../../pubspec.yaml ]; then
    echo "Error: pubspec.yaml not found in expected location. Make sure you're running this script from the correct directory."
    exit 1
fi

# Create a new macOS platform
echo "Creating new macOS platform..."
(flutter create ../../../. --org com.liphium --platforms macos -e)

# Replace the entitlements files
echo "Replacing entitlement files..."
cp ./default.entitlements ../../../macos/Runner/Release.entitlements
cp ./default.entitlements ../../../macos/Runner/DebugProfile.entitlements

echo "macOS platform has been successfully recreated with custom entitlements."