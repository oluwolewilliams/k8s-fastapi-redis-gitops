#!/bin/bash

set -e

BASE_URL="http://localhost/api"

read -p "Enter the key: " key
read -p "Enter the value: " value

echo ""
echo "Checking root endpoint through Ingress..."
curl -s "${BASE_URL}"
echo ""

echo ""
echo "Storing key-value pair through Ingress..."
curl -s -X POST "${BASE_URL}/cache?key=${key}&value=${value}"
echo ""

echo ""
echo "Retrieving key through Ingress..."
curl -s "${BASE_URL}/cache?key=${key}"
echo ""