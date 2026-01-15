# Azure Functions with Event Hubs Trigger (TypeScript)

A TypeScript Azure Functions QuickStart project that demonstrates how to use an Event Hubs Trigger with Azure Developer CLI (azd) for quick and easy deployment. This sample showcases a real-time message processing system with automated message generation and event-driven processing.

## Architecture

This architecture shows how the Azure Function processes messages through Event Hubs in real-time. The key components include:

- **Message Generator (Timer Trigger)**: Automatically generates test messages every 10 seconds and streams them to Event Hubs
- **Azure Event Hubs**: Scalable messaging service that handles high-throughput message streaming with 2 partitions
- **Message Processor (Event Hub Trigger)**: Executes automatically when messages arrive, processing and forwarding them
- **Azure Monitor**: Provides logging and metrics for function execution and message analytics
- **Downstream Integration**: Optional integration with other services for further processing

This serverless architecture enables highly scalable, event-driven message processing with built-in resiliency and automatic scaling.

## Top Use Cases

1. **Real-time Message Processing Pipeline**: Automatically process messages as they're generated or received. Perfect for scenarios where you need to transform data, perform validation, or trigger notifications when new messages arrive without polling.

2. **Event-Driven Microservices**: Build event-driven architectures where messages automatically trigger downstream business logic. Ideal for workflow orchestration, data synchronization, or integration scenarios.

## Features

- Event Hubs Trigger with high-throughput message streaming (18-30 messages/minute)
- Azure Functions Flex Consumption plan for automatic scaling
- TypeScript for type safety and modern JavaScript features
- Optional VNet integration with private endpoints for enhanced security
- Azure Developer CLI (azd) integration for easy deployment
- Infrastructure as Code using Bicep templates with Azure Verified Modules
- Comprehensive monitoring with Application Insights
- Managed Identity authentication for secure, passwordless access

## Getting Started

### Prerequisites

- [Node.js 22.x or later](https://nodejs.org/)
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local#install-the-azure-functions-core-tools)
- [Azure Developer CLI (azd)](https://docs.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azurite](https://github.com/Azure/Azurite) for local development
- An Azure subscription

### Quickstart

1. **Clone this repository**

   ```bash
   git clone https://github.com/MadhuraBharadwaj-MSFT/functions-quickstart-typescript-azd-eventhub.git
   cd functions-quickstart-typescript-azd-eventhub
   ```

2. **Make sure to run this before calling azd to provision resources so azd can run scripts required to setup permissions**

   Mac/Linux:
   ```bash
   chmod +x ./infra/scripts/*.sh
   ```

   Windows:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```

3. **Configure VNet settings (optional)**

   You can choose whether to enable VNet integration:

   For simple deployment without VNet (public endpoints):
   ```bash
   azd env set VNET_ENABLED false
   ```

   For secure deployment with VNet (private endpoints):
   ```bash
   azd env set VNET_ENABLED true
   ```

   > **Note**: If you don't set `VNET_ENABLED`, the deployment will ask you to make an explicit choice.

4. **Provision Azure resources using azd**

   ```bash
   azd provision
   ```

   This will create all necessary Azure resources including:
   - Azure Event Hubs namespace and hubs
   - Azure Function App (Flex Consumption)
   - Application Insights for monitoring
   - Storage Account for function app
   - Virtual Network with private endpoints (if `VNET_ENABLED=true`)
   - Other supporting resources
   - `local.settings.json` for local development with Azure Functions Core Tools, which should look like this:

   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "UseDevelopmentStorage=true",
       "FUNCTIONS_WORKER_RUNTIME": "node",
       "EventHubConnection__fullyQualifiedNamespace": "your-eventhubs-namespace.servicebus.windows.net"
     }
   }
   ```

   The `azd` command automatically sets up the required connection strings and application settings.

5. **Start the function locally**

   ```bash
   func start
   ```

   Or use VS Code to run the project with the built-in Azure Functions extension by pressing F5.

6. **Test the function locally by watching the automatic message generation**

   The Message Generator will automatically start creating messages every 10 seconds. You should see console output like:

   ```
   [2024-01-15T05:33:10.014Z] ⏰ Timer trigger function started
   [2024-01-15T05:33:10.020Z] ✅ Sent 3 message(s) to input Event Hub
   [2024-01-15T05:33:10.113Z] 🔄 Event hub function processing 4 message(s)
   [2024-01-15T05:33:10.115Z] ✨ Message processed: {...}
   [2024-01-15T05:33:10.121Z] 📤 Sent 4 message(s) to output Event Hub
   ```

7. **Deploy to Azure**

   ```bash
   azd up
   ```

   This will build your function app and deploy it to Azure. The deployment process:
   - Checks for any bicep changes using `azd provision`
   - Packages the TypeScript project using `azd package`
   - Publishes the function app using `azd deploy`
   - Updates application settings in Azure

8. **Test the deployed function by monitoring the logs in Azure Portal:**
   - Navigate to your Function App in the Azure Portal
   - Go to Functions → TimerTrigger or EventHubsTrigger
   - Check the Monitor tab to verify both functions are working
   - Use Application Insights Live Metrics to see real-time message processing

## Understanding the Code

This sample contains two functions that work together:

### Message Generator (Timer Trigger)

Runs every 10 seconds and generates 3-5 test messages, then sends them to Event Hubs. The key configuration:

- **Timer**: `*/10 * * * * *` (every 10 seconds)
- **Output**: Event Hubs output binding to "input-events" hub
- **Messages**: Test content with unique IDs and timestamps

### Message Processor (Event Hubs Trigger)

Triggered automatically when messages arrive in Event Hubs. Processes messages and forwards them to output hub. The key environment variable that configures its behavior is:

- `EventHubConnection__fullyQualifiedNamespace`: The Event Hubs namespace endpoint

These are automatically set up by azd during deployment for both local and cloud environments.

Here's the core implementation of the Event Hubs trigger function:

```typescript
app.eventHub('EventHubsTrigger', {
    connection: 'EventHubConnection',
    eventHubName: '%INPUT_EVENTHUB_NAME%',
    cardinality: 'many',
    handler: async (messages: unknown[], context: InvocationContext) => {
        context.log(`🔄 Event hub function processing ${messages.length} message(s)`);
        
        const processedMessages: EventMessage[] = [];
        for (const message of messages) {
            const eventMessage = message as EventMessage;
            context.log(`📨 Processing event: ${JSON.stringify(eventMessage)}`);
            
            const processedMessage: EventMessage = {
                ...eventMessage,
                timestamp: new Date().toISOString()
            };
            
            processedMessages.push(processedMessage);
            context.log(`✨ Message processed: ${JSON.stringify(processedMessage)}`);
        }
        
        context.extraOutputs.set(eventHubOutput, processedMessages);
        context.log(`📤 Sent ${processedMessages.length} message(s) to output Event Hub`);
    },
    extraOutputs: [eventHubOutput]
});
```

## Project Structure

```
functions-quickstart-typescript-azd-eventhub/
├── src/
│   └── functions/
│       ├── EventHubsTrigger.ts    # Event Hub trigger function
│       └── TimerTrigger.ts        # Timer trigger (generates messages)
├── package.json                    # Node.js dependencies
├── tsconfig.json                   # TypeScript configuration
├── host.json                       # Function host settings
├── local.settings.json             # Local development settings (generated)
├── infra/                          # Infrastructure as Code
│   ├── main.bicep                  # Main infrastructure template
│   ├── main.parameters.json        # Infrastructure parameters
│   ├── abbreviations.json          # Resource naming abbreviations
│   ├── app/                        # Modular infrastructure components
│   │   ├── api.bicep               # Function App (Flex Consumption)
│   │   ├── eventhubs.bicep         # Event Hubs namespace and hubs
│   │   ├── eventhubs-PrivateEndpoint.bicep  # Event Hubs private endpoint
│   │   ├── storage-PrivateEndpoint.bicep    # Storage private endpoints
│   │   ├── vnet.bicep              # Virtual Network configuration
│   │   └── rbac.bicep              # Role-based access control
│   └── scripts/                    # Deployment and setup scripts
│       ├── postprovision.ps1       # Post-provision setup (Windows)
│       └── postprovision.sh        # Post-provision setup (POSIX)
├── .azure/                         # Azure Developer CLI environment
├── azure.yaml                      # Azure Developer CLI configuration
└── README.md                       # This file
```

## Networking and VNet Integration

This sample supports optional VNet integration with private endpoints for enhanced security.

### Configuration

Set the `VNET_ENABLED` environment variable before deployment:

For simple deployment without VNet (public endpoints):
```bash
azd env set VNET_ENABLED false
```

For secure deployment with VNet (private endpoints):
```bash
azd env set VNET_ENABLED true
```

When `vnetEnabled=true`, the deployment creates:

- Virtual Network with three subnets (app integration, storage endpoints, Event Hub endpoints)
- Private endpoints for Storage (blob, table, queue) and Event Hubs
- Private DNS zones for name resolution
- Network isolation with public access disabled

The VNet deployment takes longer (~4-5 minutes) but provides enhanced security suitable for production workloads.

### VNet Architecture

When VNet integration is enabled, the following network architecture is created:

#### Subnets

1. App Integration Subnet: For Function App VNet integration
2. Storage Private Endpoints Subnet: For Storage Account private endpoints
3. Event Hubs Private Endpoints Subnet: For Event Hubs private endpoints

#### Private Endpoints

- **Storage Account**: Blob, Table, and Queue private endpoints
- **Event Hubs**: Namespace private endpoint

#### DNS Configuration

- Private DNS zones are automatically created and linked to the VNet
- Ensures proper name resolution for private endpoints

### Security Considerations

When using VNet integration:

- Public access to Event Hubs and Storage is disabled
- All traffic flows through private endpoints within the VNet
- Client IP must be added to Event Hubs network rules for local development (done automatically by post-provision scripts)
- Managed Identity is used for authentication between services

## Resources

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/azure/event-hubs/)
- [Azure Developer CLI Documentation](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
