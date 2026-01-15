#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo ""

# Get the outputs from the deployment
outputs=$(azd env get-values --output json)

# Extract values using jq
if command -v jq &> /dev/null; then
    eventHubsNamespace=$(echo "$outputs" | jq -r '.EVENTHUBS_CONNECTION__fullyQualifiedNamespace')
    inputEventHubName=$(echo "$outputs" | jq -r '.INPUT_EVENTHUB_NAME')
    outputEventHubName=$(echo "$outputs" | jq -r '.OUTPUT_EVENTHUB_NAME')
    functionAppName=$(echo "$outputs" | jq -r '.SERVICE_API_NAME')
else
    # Fallback using grep and sed if jq is not available
    eventHubsNamespace=$(echo "$outputs" | grep '"EVENTHUBS_CONNECTION__fullyQualifiedNamespace"' | sed 's/.*"EVENTHUBS_CONNECTION__fullyQualifiedNamespace"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    inputEventHubName=$(echo "$outputs" | grep '"INPUT_EVENTHUB_NAME"' | sed 's/.*"INPUT_EVENTHUB_NAME"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    outputEventHubName=$(echo "$outputs" | grep '"OUTPUT_EVENTHUB_NAME"' | sed 's/.*"OUTPUT_EVENTHUB_NAME"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    functionAppName=$(echo "$outputs" | grep '"SERVICE_API_NAME"' | sed 's/.*"SERVICE_API_NAME"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

echo -e "${YELLOW}Event Hub Function App deployed successfully!${NC}"
echo ""
echo -e "${CYAN}System components:${NC}"
echo -e "${WHITE}  - Event Hub Trigger Function: Processes messages from input Event Hub${NC}"
echo -e "${WHITE}  - Input Event Hub: $inputEventHubName${NC}"
echo -e "${WHITE}  - Output Event Hub: $outputEventHubName${NC}"
echo -e "${WHITE}  - Event Hubs Namespace: $eventHubsNamespace${NC}"
echo ""
echo -e "${GREEN}Function is now running in Azure!${NC}"
echo ""
echo -e "${YELLOW}Function App Name: $functionAppName${NC}"

echo -e "${YELLOW}Creating/updating local.settings.json...${NC}"

cat <<EOF > ./local.settings.json
{
    "IsEncrypted": "false",
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "node",
        "EventHubConnection__fullyQualifiedNamespace": "$eventHubsNamespace",
        "INPUT_EVENTHUB_NAME": "$inputEventHubName",
        "OUTPUT_EVENTHUB_NAME": "$outputEventHubName"
    }
}
EOF

echo -e "${GREEN}✅ local.settings.json has been created/updated successfully!${NC}"
