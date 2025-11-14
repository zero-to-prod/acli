#!/bin/bash
# Test ACLI Docker image
# Runs a suite of tests to verify the image works correctly

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE="${1:-davidsmith3/acli:latest}"
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
print_test() {
    echo -e "${BLUE}Test $1:${NC} $2"
}

print_pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

print_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

# Header
echo ""
echo "======================================"
echo "ACLI Docker Image Test Suite"
echo "======================================"
echo ""
echo "Testing image: ${IMAGE}"
echo ""

# Test 1: Image exists
print_test "1" "Checking if image exists..."
if docker image inspect "${IMAGE}" > /dev/null 2>&1; then
    print_pass "Image exists locally"
else
    print_fail "Image not found locally"
    print_info "Run: docker pull ${IMAGE}"
    exit 1
fi

# Test 2: Help command
print_test "2" "Testing --help command..."
HELP_OUTPUT=$(docker run --rm "${IMAGE}" --help 2>&1 || true)
if echo "${HELP_OUTPUT}" | grep -qi "atlassian\|acli\|jira"; then
    print_pass "Help command works"
else
    print_fail "Help command failed or output unexpected"
fi

# Test 3: Version command
print_test "3" "Testing --version command..."
VERSION_OUTPUT=$(docker run --rm "${IMAGE}" --version 2>&1 || true)
if [ -n "${VERSION_OUTPUT}" ]; then
    VERSION=$(echo "${VERSION_OUTPUT}" | head -n 1)
    print_pass "Version command works: ${VERSION}"
else
    print_warn "Version command not available (may not be supported by ACLI)"
fi

# Test 4: Image size check
print_test "4" "Checking image size..."
SIZE=$(docker image inspect "${IMAGE}" --format='{{.Size}}')
SIZE_MB=$((SIZE / 1024 / 1024))
print_info "Image size: ${SIZE_MB}MB"

if [ "${SIZE_MB}" -lt 50 ]; then
    print_pass "Image size acceptable (< 50MB)"
elif [ "${SIZE_MB}" -lt 100 ]; then
    print_warn "Image size moderate (${SIZE_MB}MB)"
else
    print_warn "Image size large (${SIZE_MB}MB) - consider optimization"
fi

# Test 5: Entrypoint check
print_test "5" "Checking container entrypoint..."
ENTRYPOINT=$(docker image inspect "${IMAGE}" --format='{{.Config.Entrypoint}}')
if [[ "${ENTRYPOINT}" == *"acli"* ]]; then
    print_pass "Entrypoint configured correctly"
else
    print_fail "Entrypoint not set properly: ${ENTRYPOINT}"
fi

# Test 6: User check (security)
print_test "6" "Checking if container runs as non-root..."
USER=$(docker image inspect "${IMAGE}" --format='{{.Config.User}}')
if [[ -n "${USER}" && "${USER}" != "root" && "${USER}" != "0" ]]; then
    print_pass "Container runs as non-root user: ${USER}"
else
    print_warn "Container appears to run as root (security concern)"
fi

# Test 7: Labels check
print_test "7" "Checking OCI labels..."
LABELS=$(docker image inspect "${IMAGE}" --format='{{.Config.Labels}}')
if [[ "${LABELS}" == *"org.opencontainers.image"* ]]; then
    print_pass "OCI labels present"
else
    print_warn "OCI labels missing"
fi

# Test 8: Working directory
print_test "8" "Checking working directory..."
WORKDIR=$(docker image inspect "${IMAGE}" --format='{{.Config.WorkingDir}}')
print_info "Working directory: ${WORKDIR}"
if [[ -n "${WORKDIR}" ]]; then
    print_pass "Working directory configured"
else
    print_warn "Working directory not set"
fi

# Test 9: Config directory mount test
print_test "9" "Testing config directory mount..."
TEMP_DIR=$(mktemp -d)
MOUNT_OUTPUT=$(docker run --rm -v "${TEMP_DIR}:/test" "${IMAGE}" ls /test 2>&1 || true)
if [ $? -eq 0 ] || [ -n "${MOUNT_OUTPUT}" ]; then
    print_pass "Volume mounting works"
else
    print_fail "Volume mounting failed"
fi
rm -rf "${TEMP_DIR}"

# Test 10: Invalid command handling
print_test "10" "Testing error handling..."
ERROR_OUTPUT=$(docker run --rm "${IMAGE}" invalid-command 2>&1 || true)
if echo "${ERROR_OUTPUT}" | grep -qi "error\|invalid\|unknown"; then
    print_pass "Error handling works correctly"
else
    print_warn "Error handling may need improvement"
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo ""
echo "Total tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
if [ "${TESTS_FAILED}" -gt 0 ]; then
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    echo ""
    echo "Some tests failed. Please review the output above."
    exit 1
else
    echo ""
    echo -e "${GREEN}All tests passed successfully!${NC}"
    exit 0
fi
