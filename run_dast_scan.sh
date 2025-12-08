#!/bin/bash
set -e


mkdir -p dast_logs

TARGET_URL="http://localhost:8000"

echo "Running Nikto scan on $TARGET_URL..."


nikto -h "$TARGET_URL" -o dast_logs/nikto.log -Format txt

echo "Nikto scan completed. Logs are in dast_logs/nikto.log"

