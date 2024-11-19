#!/bin/bash

# Check if the webhook URL is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <webhook_url>"
  exit 1
fi

WEBHOOK_URL="$1"

# Find all generated XML reports
XML_REPORTS=$(find ./test-results/cypress -name "*.xml")

# Initialize variables to store total test counts
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TIME=0

# Loop through each XML report and accumulate test counts
for report in $XML_REPORTS; do
  TOTAL_TESTS=$((TOTAL_TESTS + $(grep -o '<testsuites.*tests="[^"]*' "$report" | sed 's/.*tests="\([^"]*\).*/\1/')))
  FAILED_TESTS=$((FAILED_TESTS + $(grep -o '<testsuites.*failures="[^"]*' "$report" | sed 's/.*failures="\([^"]*\).*/\1/')))
  TIME=$(awk -v time="$TIME" '
      BEGIN { FS="time=\""; total = time }
      /<testsuites.*time="/ {
          match($2, /^[^"]+/)
          total += substr($2, RSTART, RLENGTH)
      }
      END { print total }
  ' "$report")
  PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))
done

# URL to view detailed test results
ACTION_URL="https://bitbucket.org/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/pipelines/results/${BITBUCKET_BUILD_NUMBER}"

# Adaptive Card JSON payload
JSON="{\
\"type\": \"message\",\
\"attachments\": [{\
  \"contentType\": \"application/vnd.microsoft.card.adaptive\",\
  \"content\": {\
    \"type\": \"AdaptiveCard\",\
    \"body\": [\
      {\
        \"type\": \"TextBlock\",\
        \"text\": \"Test Automation Run Summary\",\
        \"weight\": \"bolder\",\
        \"size\": \"extraLarge\",\
        \"height\": \"stretch\",\
        \"wrap\": true\
      },\
      {\
        \"type\": \"TextBlock\",\
        \"text\": \"Here are the results of the latest test automation run.\",\
        \"size\": \"medium\",\
        \"weight\": \"bolder\",\
        \"height\": \"stretch\",\
        \"wrap\": true\
      },\
      {\
        \"type\": \"FactSet\",\
        \"facts\": [\
          {\
            \"title\": \"Repository:\",\
            \"value\": \"${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}\"\
          },\
          {\
            \"title\": \"Branch:\",\
            \"value\": \"${BITBUCKET_BRANCH}\"\
          },\
          {\
            \"title\": \"Commit:\",\
            \"value\": \"${BITBUCKET_COMMIT}\"\
          },\
          {\
            \"title\": \"Build Number:\",\
            \"value\": \"${BITBUCKET_BUILD_NUMBER}\"\
          },\
          {\
            \"title\": \"Total Tests:\",\
            \"value\": \"${TOTAL_TESTS}\"\
          },\
          {\
            \"title\": \"Passed Tests:\",\
            \"value\": \"${PASSED_TESTS}\"\
          },\
          {\
            \"title\": \"Failed Tests:\",\
            \"value\": \"${FAILED_TESTS}\"\
          },\
          {\
            \"title\": \"Test Run Time:\",\
            \"value\": \"${TIME} seconds\"\
          },\
        ],\
        \"separator\": \"true\",\
        \"spacing\": \"Large\",\
      }\
    ],\
    \"actions\": [{\
      \"type\": \"Action.OpenUrl\",\
      \"title\": \"View Pipeline\",\
      \"url\": \"${ACTION_URL}\"\
    }],\
    \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\",\
    \"version\": \"1.3\"\
  }\
}],\
\"summary\": \"Summary of the latest test automation run.\"\
}"

# Compose the notification to Microsoft Teams
CURL_OUTPUT=$(curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" 2>&1)
CURL_EXIT_STATUS=$?

# Check the exit status of curl
if [ $CURL_EXIT_STATUS -eq 0 ]; then
  echo "Microsoft Teams notification was sent"
else
  echo "Failed to send Microsoft Teams notification. Error details:"
  echo "$CURL_OUTPUT"
fi
