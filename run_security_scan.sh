#!/bin/bash

set -e

PROJECT_DIR="$(pwd)"
LOG_DIR="$PROJECT_DIR/security_logs"
mkdir -p "$LOG_DIR"

# Paths for tools from venv
SEMGREP="./devsecops-venv/bin/semgrep"
TRUFFLEHOG="./devsecops-venv/bin/trufflehog"

echo "====================="
echo "1️⃣  Running Semgrep..."
echo "====================="
$SEMGREP scan --config auto "$PROJECT_DIR" > "$LOG_DIR/semgrep.log" 2>&1 || true
echo "Semgrep scan completed. See $LOG_DIR/semgrep.log for details."

echo ""
echo "====================="
echo "2️⃣  Running TruffleHog..."
echo "====================="
# Python version supports ONLY: trufflehog <path> --json
$TRUFFLEHOG "$PROJECT_DIR" --json > "$LOG_DIR/trufflehog.json" 2>&1 || true
echo "TruffleHog scan completed. See $LOG_DIR/trufflehog.json for details."

echo ""
echo "====================="
echo "3️⃣  Running Trivy..."
echo "====================="
trivy fs --security-checks vuln,secret "$PROJECT_DIR" > "$LOG_DIR/trivy.log" 2>&1 || true
echo "Trivy scan completed. See $LOG_DIR/trivy.log for details."

echo ""
echo "✅ Security scan completed! All logs are in $LOG_DIR"

