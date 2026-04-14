#!/bin/bash

set -e

BASE_URL="http://localhost:8000"

read -p "Enter the key: " key
read -p "Enter the value: " value

echo ""
echo "Checking root endpoint..."
curl -s "${BASE_URL}/"
echo ""

echo ""
echo "Storing key-value pair..."
curl -s -X POST "${BASE_URL}/cache?key=${key}&value=${value}"
echo ""

echo ""
echo "Retrieving key..."
curl -s "${BASE_URL}/cache?key=${key}"
echo ""