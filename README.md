# Azure Functions TypeScript - Event Hubs Sample

An Azure Functions quickstart project demonstrating Event Hubs integration with TypeScript and Azure Developer CLI (azd). This sample showcases an automated message processing system with timer-based message generation and event-driven processing.

## Features

- **Timer Trigger**: Automatically generates 3-5 test messages every minute
- **Event Hub Trigger**: Processes messages from Event Hubs with batching support
- **Event Hub Output Binding**: Sends processed messages to output Event Hub
- **TypeScript**: Full type safety and modern JavaScript features  
- **Emoji Logging**: Enhanced logging with emojis for better visibility
- **Azure Verified Modules (AVM)**: Production-ready Bicep infrastructure
- **Managed Identity**: Passwordless, secure authentication throughout
- **Flex Consumption**: Automatic scaling with Azure Functions Flex Consumption plan
- **Optional VNet Integration**: Support for private endpoints and network isolation

## Architecture

```
Timer Trigger (every minute)
    ↓
Input Event Hub → Event Hub Trigger → Output Event Hub
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
│       ├── EventHubsTrigger.ts    # Event Hub trigger function
│       └── TimerTrigger.ts        # Timer trigger (generates messages)
├── infra/                          # Bicep infrastructure files
│   ├── main.bicep                  # Main deployment template
│   ├── main.parameters.json        # Deployment parameters
│   ├── abbreviations.json          # Resource naming conventions
│   ├── app/                        # Modular infrastructure components
│   │   ├── api.bicep               # Function App (Flex Consumption)
│   │   ├── eventhubs.bicep         # Event Hubs namespace and hubs
│   │   ├── eventhubs-PrivateEndpoint.bicep  # Event Hubs private endpoint
│   │   ├── storage-PrivateEndpoint.bicep    # Storage private endpoints
│   │   ├── vnet.bicep              # Virtual Network configuration
│   │   └── rbac.bicep              # Role-based access control
│   └── scripts/                    # Deployment scripts
│       ├── postprovision.ps1       # Post-provision setup (Windows)
│       └── postprovision.sh        # Post-provision setup (POSIX)
├── package.json
├── tsconfig.json
├── host.json
├── local.settings.json
└── azure.yaml                      # Azure Developer CLI configuration
```

## Function Logic

### TimerTrigger
- Runs every minute (configurable via cron schedule)
- Generates 3-5 random test messages
- Sends messages to `input-events` Event Hub
- Logs with ⏰, 📝, and ✅ emojis

### EventHubsTrigger  
- Triggered by messages in `input-events` Event Hub
- Processes messages in batches (cardinality: many)
- Adds processing metadata and timestamps
- Sends processed messages to `output-events` Event Hub
- Logs with 🔄, 📨, ✨, and 📤 emojis

## Local Development

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Local Settings

The `azd provision` command automatically creates `local.settings.json` via a post-provision hook:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
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

2. **Provision and deploy**:
   ```bash
   azd up
   ```

   This command will:
   - Prompt for environment name and Azure location
   - Ask whether to enable VNet integration (optional)
   - Create all Azure resources (Event Hubs, Function App, Storage, Application Insights)
   - Deploy your function code
   - Configure all connections and settings with managed identity
   - Create `local.settings.json` for local development

### What Gets Deployed

- **Event Hubs Namespace** with two hubs:
  - `input-events` (2 partitions)
  - `output-events` (2 partitions)
- **Function App** on Flex Consumption plan (FC1 SKU)
- **Application Insights** for monitoring
- **Storage Account** for function app storage
- **User-Assigned Managed Identity** for authentication
- **RBAC Role Assignments** for secure access
- **Optional**: VNet, Private Endpoints, and DNS zones

## Testing

### Automated Testing (Recommended)

The deployed function automatically generates and processes messages every minute via the TimerTrigger. No manual message sending required!

### Monitor Function Execution

**View in Application Insights Logs**:
```bash
# Query recent function executions
az monitor app-insights query \
  --app <app-insights-name> \
  --analytics-query "traces | where timestamp > ago(5m) | project timestamp, operation_Name, message | order by timestamp desc"
```

Or use the Azure Portal:
1. Navigate to Application Insights → Logs
2. Run this query:
   ```kusto
   traces 
   | where timestamp > ago(5m) 
   | where operation_Name in ("TimerTrigger", "EventHubsTrigger")
   | project timestamp, operation_Name, message 
   | order by timestamp desc
   ```

### Manual Message Sending (Optional)

To send custom test messages to the input Event Hub, use Azure Portal:
1. Go to Event Hubs namespace → `input-events`
2. Click "Send events"
3. Send JSON message:
   ```json
   {"id": "test-1", "message": "Hello from manual test!"}
   ```

## Configuration

### Environment Variables

| Variable | Description |
|----------|-------------|
| `EventHubConnection__fullyQualifiedNamespace` | Event Hub namespace FQDN (uses managed identity) |
| `INPUT_EVENTHUB_NAME` | Name of the input Event Hub (default: `input-events`) |
| `OUTPUT_EVENTHUB_NAME` | Name of the output Event Hub (default: `output-events`) |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string |
| `AZURE_CLIENT_ID` | Managed identity client ID for authentication |

### Managed Identity

The Function App uses **managed identity** for passwordless authentication to:
- Event Hubs (Data Receiver and Sender roles)
- Storage Account (Blob Data Owner, Table Data Contributor)
- Application Insights (Monitoring Metrics Publisher)

Your user identity is also automatically assigned these roles for local development.

### VNet Integration

Enable VNet integration during deployment:
```bash
azd env set VNET_ENABLED true
azd provision
```

When enabled, the deployment creates:
- Virtual Network with three subnets
- Private endpoints for Event Hubs and Storage
- Private DNS zones for name resolution
- Network isolation with public access disabled

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
