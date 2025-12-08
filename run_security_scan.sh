#!/bin/bash
set -e

PROJECT_DIR="$(pwd)"

# Основные каталоги логов
LOG_DIR="$PROJECT_DIR/security_logs"
DAST_DIR="$PROJECT_DIR/dast_logs"

mkdir -p "$LOG_DIR"
mkdir -p "$DAST_DIR"

SEMGREP="./devsecops-venv/bin/semgrep"
TRUFFLEHOG="./devsecops-venv/bin/trufflehog"

echo ""
echo "====================="
echo "1️⃣  Running Semgrep..."
echo "====================="

$SEMGREP scan --config auto "$PROJECT_DIR" > "$LOG_DIR/semgrep.log" 2>&1 || true

echo "Semgrep scan completed. See $LOG_DIR/semgrep.log for details."
echo "===== Semgrep Output ====="
cat "$LOG_DIR/semgrep.log"


echo "====================="
echo "2️⃣  Running TruffleHog (secret scan)..."
echo "====================="

$TRUFFLEHOG --entropy=True --json "$PROJECT_DIR" \
  > "$LOG_DIR/trufflehog.json" 2>&1 || true

echo "TruffleHog scan completed. See $LOG_DIR/trufflehog.json for details."
echo "===== TruffleHog Output ====="
cat "$LOG_DIR/trufflehog.json"



echo ""
echo "====================="
echo "3️⃣  Running Trivy..."
echo "====================="

# Trivy установлен через .deb и находится в PATH
trivy fs --security-checks vuln,secret "$PROJECT_DIR" \
  > "$LOG_DIR/trivy.log" 2>&1 || true

echo "Trivy scan completed. See $LOG_DIR/trivy.log for details."
echo "===== Trivy Output ====="
cat "$LOG_DIR/trivy.log"


echo ""
echo "====================="
echo "4️⃣  Running Nikto (DAST)..."
echo "====================="

# IMPORTANT: Nikto работает только против HTTP-сервера
# Убедись, что твой сервис запускается перед этим шагом
nikto -h http://localhost:8001 \
  -o "$DAST_DIR/nikto.log" -Format txt || true

echo "Nikto scan completed. See $DAST_DIR/nikto.log for details."
echo "===== Nikto Output ====="
cat "$DAST_DIR/nikto.log"

