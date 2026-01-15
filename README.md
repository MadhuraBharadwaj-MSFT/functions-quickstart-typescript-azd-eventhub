# Azure Functions Event Hubs - TypeScript

This project demonstrates an Azure Functions application written in TypeScript that processes messages from Azure Event Hubs. It includes an Event Hub trigger function that reads messages from an input Event Hub, processes them, and sends the processed messages to an output Event Hub.

## Features

- **Event Hub Trigger**: Automatically processes messages from an input Event Hub
- **Event Hub Output Binding**: Sends processed messages to an output Event Hub
- **TypeScript**: Full type safety and modern JavaScript features
- **Infrastructure as Code**: Complete Bicep templates for Azure resources
- **Azure Developer CLI**: Streamlined deployment with `azd`

## Architecture

```
Input Event Hub → Azure Function → Output Event Hub
                      ↓
              Application Insights
```

## Prerequisites

- [Node.js 22.x or later](https://nodejs.org/)
- [Azure Functions Core Tools v4](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
- [Azure Developer CLI (azd)](https://aka.ms/azd-install)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription

## Project Structure

```
.
├── src/
│   └── functions/
│       └── EventHubsTrigger.ts    # Event Hub trigger function
├── infra/                          # Bicep infrastructure files
│   ├── main.bicep                  # Main deployment template
│   ├── resources.bicep             # Event Hub resources
│   ├── functionapp.bicep           # Function App configuration
│   ├── monitor.bicep               # Application Insights
│   ├── storage.bicep               # Storage account
│   ├── abbreviations.json          # Resource naming conventions
│   └── main.parameters.json        # Deployment parameters
├── package.json
├── tsconfig.json
├── host.json
├── local.settings.json
└── azure.yaml                      # Azure Developer CLI configuration
```

## Function Logic

The `EventHubsTrigger` function:
1. Receives messages from the input Event Hub
2. Parses and processes each message
3. Adds metadata (ID, timestamp)
4. Sends processed messages to the output Event Hub
5. Logs processing information to Application Insights

## Local Development

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Local Settings

Create or update `local.settings.json`:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "EventHubConnection__fullyQualifiedNamespace": "<your-eventhub-namespace>.servicebus.windows.net",
    "INPUT_EVENTHUB_NAME": "input-events",
    "OUTPUT_EVENTHUB_NAME": "output-events"
  }
}
```

### 3. Build the Project

```bash
npm run build
```

### 4. Run Locally

```bash
npm start
```

## Deploy to Azure

### Using Azure Developer CLI (Recommended)

1. **Login to Azure**:
   ```bash
   azd auth login
   ```

2. **Initialize the environment**:
   ```bash
   azd env new
   ```
   Enter an environment name (e.g., "dev").

3. **Provision and deploy**:
   ```bash
   azd up
   ```

This command will:
- Create all Azure resources (Event Hubs, Function App, Storage, Application Insights)
- Deploy your function code
- Configure all connections and settings

### Manual Deployment

1. **Create Azure resources**:
   ```bash
   az group create --name rg-eventhubs-typescript --location eastus
   az deployment group create --resource-group rg-eventhubs-typescript --template-file infra/main.bicep
   ```

2. **Deploy function code**:
   ```bash
   npm run build
   func azure functionapp publish <function-app-name>
   ```

## Testing

### Send Test Messages

Use Azure CLI to send test messages to the input Event Hub:

```bash
# Install jq if not already installed (for JSON processing)
# On Windows: choco install jq
# On macOS: brew install jq
# On Linux: sudo apt-get install jq

# Send a test message
az eventhubs eventhub message send \
  --namespace-name <your-namespace> \
  --eventhub-name input-events \
  --messages '[{"id": "1", "message": "Hello from CLI"}]'
```

### Monitor Function Execution

1. **View logs in the portal**:
   - Navigate to your Function App in Azure Portal
   - Go to "Monitor" → "Logs"

2. **View in Application Insights**:
   ```bash
   az monitor app-insights query \
     --app <app-insights-name> \
     --analytics-query "traces | where message contains 'Event hub function' | order by timestamp desc | take 20"
   ```

3. **Check output Event Hub**:
   - Verify processed messages in the output Event Hub using Azure Portal or Event Hub Explorer

## Configuration

### Environment Variables

| Variable | Description |
|----------|-------------|
| `EventHubConnection__fullyQualifiedNamespace` | Event Hub namespace (uses managed identity) |
| `INPUT_EVENTHUB_NAME` | Name of the input Event Hub |
| `OUTPUT_EVENTHUB_NAME` | Name of the output Event Hub |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string |

### Managed Identity

The Function App uses managed identity to connect to Event Hubs. The infrastructure automatically assigns the "Event Hubs Data Owner" role to both your user account and the Function App's managed identity.

## Troubleshooting

### Function not triggering
- Verify the Event Hub connection string and names
- Check that messages are being sent to the input Event Hub
- Review Application Insights logs for errors

### Authentication errors
- Ensure managed identity is enabled on the Function App
- Verify role assignments (Event Hubs Data Owner) are configured
- Check that the namespace FQDN is correct in settings

### Build errors
- Run `npm install` to ensure all dependencies are installed
- Check TypeScript version compatibility
- Verify Node.js version (22.x or later)

## Clean Up

To delete all Azure resources:

```bash
azd down
```

Or manually:

```bash
az group delete --name rg-eventhubs-typescript
```

## Resources

- [Azure Functions TypeScript Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-node)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/azure/event-hubs/)
- [Azure Developer CLI](https://aka.ms/azd)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

## License

This project is licensed under the MIT License.
