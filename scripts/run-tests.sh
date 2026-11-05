
#!/usr/bin/env bash

set -euo pipefail

echo "=================================="
echo "       TEST PIPELINE STARTED      "
echo "=================================="

echo ""
echo "=== BUILD INFORMATION ==="
echo "Source Build ID:     $SOURCE_BUILD_ID"
echo "Source Build Number: $SOURCE_BUILD_NUMBER"
echo "Source Branch:       $SOURCE_BRANCH"

echo ""
echo "=== CUSTOM PARAMETERS ==="
echo "Custom Message: $CUSTOM_MESSAGE"
echo "Release Tag:    $RELEASE_TAG"

echo ""
echo "=== TEST CONFIGURATION ==="

echo "Environment: $(jq -r '.environment' <<< "$TEST_CONFIG_JSON")"
echo "Suite:       $(jq -r '.suite' <<< "$TEST_CONFIG_JSON")"
echo "Retry Count: $(jq -r '.retryCount' <<< "$TEST_CONFIG_JSON")"
echo "Notify Team: $(jq -r '.notifyTeam' <<< "$TEST_CONFIG_JSON")"
echo "Browsers:    $(jq -r '.browsers | join(", ")' <<< "$TEST_CONFIG_JSON")"

echo ""
echo "=== METADATA ==="

echo "Owner:    $(jq -r '.metadata.owner' <<< "$TEST_CONFIG_JSON")"
echo "Ticket:   $(jq -r '.metadata.ticket' <<< "$TEST_CONFIG_JSON")"
echo "Priority: $(jq -r '.metadata.priority' <<< "$TEST_CONFIG_JSON")"

echo ""
echo "=== COMPLETE JSON ==="
jq . <<< "$TEST_CONFIG_JSON"

echo ""
echo "=================================="
echo "       TESTS COMPLETED            "
echo "=================================="
