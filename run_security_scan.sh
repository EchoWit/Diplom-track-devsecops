#!/bin/bash

# Проект и логи
PROJECT_DIR="$(pwd)"
LOG_DIR="$PROJECT_DIR/security_logs"
mkdir -p "$LOG_DIR"

echo "====================="
echo "1️⃣  Running Semgrep..."
echo "====================="
semgrep --config=auto "$PROJECT_DIR" > "$LOG_DIR/semgrep.log" 2>&1
echo "Semgrep scan completed. See $LOG_DIR/semgrep.log for details."

echo ""
echo "====================="
echo "2️⃣  Running TruffleHog..."
echo "====================="
trufflehog --repo_path "$PROJECT_DIR" --json > "$LOG_DIR/trufflehog.json" 2>&1 || echo "TruffleHog scan finished with warnings."
echo "TruffleHog scan completed. See $LOG_DIR/trufflehog.json for details."

echo ""
echo "====================="
echo "3️⃣  Running Trivy..."
echo "====================="
trivy fs --security-checks vuln,secret "$PROJECT_DIR" > "$LOG_DIR/trivy.log" 2>&1
echo "Trivy scan completed. See $LOG_DIR/trivy.log for details."

echo ""
echo "✅ Security scan completed! All logs are in $LOG_DIR"

