#!/bin/bash
set -e

PROJECT_DIR="$(pwd)"
LOG_DIR="$PROJECT_DIR/security_logs"
mkdir -p "$LOG_DIR"

SEMGREP="./devsecops-venv/bin/semgrep"
TRUFFLEHOG="./devsecops-venv/bin/trufflehog"

echo "====================="
echo "1️⃣  Running Semgrep..."
echo "====================="
$SEMGREP scan --config auto "$PROJECT_DIR" > "$LOG_DIR/semgrep.log" 2>&1 || true
echo "Semgrep scan completed. See $LOG_DIR/semgrep.log for details."
echo "===== Semgrep Output ====="
cat "$LOG_DIR/semgrep.log"   # выводим содержимое в Actions

echo ""
echo "====================="
echo "2️⃣  Running TruffleHog (filesystem scan)..."
echo "====================="
$TRUFFLEHOG filesystem "$PROJECT_DIR" --json > "$LOG_DIR/trufflehog.json" 2>&1 || echo "TruffleHog scan finished with warnings."
echo "TruffleHog scan completed. See $LOG_DIR/trufflehog.json for details."
echo "===== TruffleHog Output ====="
cat "$LOG_DIR/trufflehog.json"   # вывод в Actions

echo ""
echo "====================="
echo "3️⃣  Running Trivy..."
echo "====================="

/snap/bin/trivy fs --security-checks vuln,secret "$PROJECT_DIR" > "$LOG_DIR/trivy.log" 2>&1 || true

echo "Trivy scan completed. See $LOG_DIR/trivy.log for details."

echo "===== Trivy Output ====="
cat "$LOG_DIR/trivy.log"


echo ""
echo "====================="
echo "4️⃣  Running Nikto (DAST)..."
echo "====================="
mkdir -p "$LOG_DIR/dast"
nikto -h http://localhost:8001 -o "$LOG_DIR/nikto.log" -Format txt || true
echo "Nikto scan completed. See $LOG_DIR/nikto.log for details."
echo "===== Nikto Output ====="
cat "$LOG_DIR/nikto.log"

echo ""
echo "✅ Security scan completed! All logs are in $LOG_DIR"
