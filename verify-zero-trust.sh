#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT="imposing-fx-413205"
STATE_BUCKET="marcel-paved-road-tfstate"
AUDIT_BUCKET="marcel-tfstate-audit-logs"
KEY_RING="terraform-state-keyring"
KEY_NAME="terraform-state-key"
LOCATION="us-central1"

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE} Zero Trust GCS Bucket Validation Report${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

PASSED=0
FAILED=0

# Helper function
check_pass() {
echo -e "${GREEN}✅ PASS${NC} - $1"
((PASSED++))
}

check_fail() {
echo -e "${RED}❌ FAIL${NC} - $1"
((FAILED++))
}

check_warn() {
echo -e "${YELLOW}⚠ WARN${NC} - $1"
((PASSED++))
}

# ============================================
# Section 1: Bucket Existence
# ============================================
echo -e "${BLUE}--- Bucket Existence ---${NC}"

if gcloud storage buckets describe gs://$STATE_BUCKET &>/dev/null; then
check_pass "State bucket exists: $STATE_BUCKET"
else
check_fail "State bucket does not exist: $STATE_BUCKET"
fi

if gcloud storage buckets describe gs://$AUDIT_BUCKET &>/dev/null; then
check_pass "Audit bucket exists: $AUDIT_BUCKET"
else
check_fail "Audit bucket does not exist: $AUDIT_BUCKET"
fi

echo ""

# ============================================
# Section 2: State Bucket Security
# ============================================
echo -e "${BLUE}--- State Bucket Security Settings ---${NC}"

BUCKET_INFO=$(gcloud storage buckets describe gs://$STATE_BUCKET --format="yaml" 2>/dev/null)

# Uniform Bucket Level Access
UBLA=$(echo "$BUCKET_INFO" | grep -i "uniform_bucket_level_access:" | awk '{print $2}')
[[ "$UBLA" == "true" ]] && check_pass "Uniform Bucket Level Access" || check_fail "Uniform Bucket Level Access: $UBLA"

# Versioning
VERSIONING=$(echo "$BUCKET_INFO" | grep -i "versioning_enabled:" | awk '{print $2}')
[[ "$VERSIONING" == "true" ]] && check_pass "Versioning Enabled" || check_fail "Versioning: $VERSIONING"

# CMEK Encryption
CMEK=$(echo "$BUCKET_INFO" | grep -i "default_kms_key:" | awk '{print $2}')
if [[ -n "$CMEK" ]]; then
check_pass "CMEK Encryption: ${CMEK##*/}"
else
check_fail "CMEK Encryption - Not configured"
fi

# Logging
LOG_BUCKET=$(echo "$BUCKET_INFO" | awk '/logging_config:/{flag=1; next} flag && /logBucket:/{print $2; exit}')
LOG_PREFIX=$(echo "$BUCKET_INFO" | awk '/logging_config:/{flag=1; next} flag && /logObjectPrefix:/{print $2; exit}')

if [[ -z "$LOG_BUCKET" ]]; then
check_fail "Logging not configured"
elif [[ "$LOG_BUCKET" != "$AUDIT_BUCKET" ]]; then
check_fail "Logging bucket mismatch: $LOG_BUCKET"
elif [[ -z "$LOG_PREFIX" ]]; then
check_warn "Logging prefix missing (logs may still work)"
else
check_pass "Logging configured to: $LOG_BUCKET (prefix: $LOG_PREFIX)"
fi
# Public Access Prevention
PAP=$(echo "$BUCKET_INFO" | grep -i "public_access_prevention:" | awk '{print $2}')
[[ "$PAP" == "enforced" || "$PAP" == "inherited" ]] && check_pass "Public Access Prevention: $PAP" || check_fail "Public Access Prevention: $PAP"

echo ""

# ============================================
# Section 3: Audit Bucket Security
# ============================================
echo -e "${BLUE}--- Audit Bucket Security Settings ---${NC}"

AUDIT_INFO=$(gcloud storage buckets describe gs://$AUDIT_BUCKET --format="yaml" 2>/dev/null)

# Uniform Access
AUDIT_UBLA=$(echo "$AUDIT_INFO" | grep -i "uniform_bucket_level_access:" | awk '{print $2}')
[[ "$AUDIT_UBLA" == "true" ]] && check_pass "Audit Bucket - Uniform Access" || check_fail "Audit Bucket - Uniform Access: $AUDIT_UBLA"

# Versioning
AUDIT_VERSIONING=$(echo "$AUDIT_INFO" | grep -i "versioning_enabled:" | awk '{print $2}')
[[ "$AUDIT_VERSIONING" == "true" ]] && check_pass "Audit Bucket - Versioning" || check_fail "Audit Bucket - Versioning: $AUDIT_VERSIONING"

# Retention
RETENTION=$(echo "$AUDIT_INFO" | grep -i "retentionPeriod:" | awk '{print $2}' | tr -d "'")
if [[ -n "$RETENTION" ]]; then
DAYS=$((RETENTION / 86400))
check_pass "Audit Bucket Retention: $DAYS days"
else
check_warn "Audit Bucket Retention not configured (optional)"
fi

echo ""

# ============================================
# Section 4: CMEK Key Status
# ============================================
echo -e "${BLUE}--- CMEK Key Status ---${NC}"

if gcloud kms keys describe "$KEY_NAME" \
--project="$PROJECT" \
--location="$LOCATION" \
--keyring="$KEY_RING" &>/dev/null; then
check_pass "KMS Key exists: $KEY_NAME"

KEY_STATE=$(gcloud kms keys versions list \
--project="$PROJECT" \
--location="$LOCATION" \
--keyring="$KEY_RING" \
--key="$KEY_NAME" \
--format="get(state)" 2>/dev/null | head -1)

[[ "$KEY_STATE" == "ENABLED" ]] && check_pass "KMS Key is ENABLED" || check_fail "KMS Key state: $KEY_STATE"
else
check_fail "KMS Key does not exist"
fi

echo ""

# ============================================
# Section 5: IAM Permissions
# ============================================
echo -e "${BLUE}--- IAM Permissions ---${NC}"

STORAGE_SA="service-915035381641@gs-project-accounts.iam.gserviceaccount.com"
KMS_BINDING=$(gcloud kms keys get-iam-policy "$KEY_NAME" \
--project="$PROJECT" \
--location="$LOCATION" \
--keyring="$KEY_RING" \
--format="json" 2>/dev/null)

if echo "$KMS_BINDING" | grep -q "$STORAGE_SA"; then
check_pass "Storage SA has KMS permissions"
else
check_fail "Storage SA missing KMS permissions"
fi

echo ""

# ============================================
# Section 6: Logging Verification
# ============================================
echo -e "${BLUE}--- Logging Verification ---${NC}"

LOG_COUNT=$(gcloud storage ls gs://$AUDIT_BUCKET/terraform-state-access/ 2>/dev/null | wc -l)

if [[ $LOG_COUNT -gt 0 ]]; then
check_pass "Logging is active ($LOG_COUNT log entries found)"
else
check_warn "No logs detected yet (logging may still be propagating)"
fi

echo ""

# ============================================
# Summary
# ============================================
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE} Summary Report${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
echo -e "${GREEN}ZERO TRUST VALIDATION COMPLETE - ALL CHECKS PASSED!${NC}"
exit 0
else
echo -e "${RED}⚠️ ZERO TRUST VALIDATION FAILED - $FAILED check(s) need attention${NC}"
exit 1
fi
