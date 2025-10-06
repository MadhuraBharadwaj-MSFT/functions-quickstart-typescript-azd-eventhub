# Azure Functions TypeScript Event Hub Trigger Quickstart

This repository contains a TypeScript Azure Functions project configured to work with Event Hub triggers using the local Event Hub emulator.

## Prerequisites

- [Node.js](https://nodejs.org/) (v20 or later)
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Docker](https://docs.docker.com/get-docker/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (optional, for testing)

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/MadhuraBharadwaj-MSFT/functions-quickstart-typescript-azd-eventhub.git
   cd functions-quickstart-typescript-azd-eventhub
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Copy local settings**
   ```bash
   copy local.settings.json.example local.settings.json
   ```
   
   Or on Windows PowerShell:
   ```powershell
   Copy-Item local.settings.json.example local.settings.json
   ```

4. **Start the Event Hub emulator**
   ```bash
   docker-compose up -d
   ```

5. **Build the TypeScript project**
   ```bash
   npm run build
   ```

6. **Start the Azure Functions host**
   ```bash
   func start
   ```

## Project Structure

- `src/functions/eventHubTrigger1.ts` - Event Hub trigger function
- `src/index.ts` - Main entry point
- `config.json` - Event Hub emulator configuration
- `docker-compose.yaml` - Docker Compose configuration for Event Hub and Azurite emulators
- `local.settings.json.example` - Example local settings file

## Event Hub Configuration

The Event Hub emulator is configured with:
- **Namespace**: `emulatorNs1`
- **Event Hub**: `eh1`
- **Consumer Group**: `cg1`
- **Partitions**: 2

## Testing

Once everything is running, you can test the Event Hub trigger by sending messages to the emulator.

### Quick Test

This repository includes a test script to easily send messages to the Event Hub emulator:

```bash
# Send a test message
node send-test-message.js
```

The script will:
- Connect to the local Event Hub emulator
- Send a message with timestamp and random test number
- Display confirmation and message content
- Trigger your Azure Functions Event Hub trigger

### Expected Output

When you run the test script, you should see:
```
🚀 Sending test message to Event Hub emulator...
✅ Message sent successfully!
📋 Message content: {
  "message": "Hello from test script - 1!",
  "timestamp": "2025-10-06T17:58:33.175Z",
  "testNumber": 189
}
👀 Check your Azure Functions terminal for the trigger execution...
```

In your Azure Functions terminal, you should see the function execution:
```
[2025-10-06T17:55:51.636Z] Event hub function processed 1 messages
[2025-10-06T17:55:51.638Z] Event hub message: {
  message: 'Hello from test script - 1!',
  timestamp: '2025-10-06T17:58:33.175Z',
  testNumber: 189
}
[2025-10-06T17:55:51.664Z] Executed 'Functions.eventHubTrigger1' (Succeeded, Duration=126ms)
```

### Troubleshooting Testing

**If the function doesn't trigger:**
1. Ensure all containers are running: `docker ps`
2. Check if the Functions host is running on port 7071
3. Verify the Event Hub emulator health: `Invoke-WebRequest -Uri "http://localhost:5300/health" -Method GET`
4. Restart the Functions host with verbose logging: `func start --verbose`

**If messages aren't processed after the first one:**
- This is normal behavior due to Event Hub checkpointing
- Restart the Functions host and send a new message
- The trigger reads from the latest position when it starts

### Manual Testing with Different Tools

You can also test using other methods:

1. **Using Azure CLI** (if available):
   ```bash
   az eventhubs eventhub send --connection-string "Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;" --eventhub-name eh1 --body "Test message"
   ```

2. **Using Kafka tools** (Event Hub supports Kafka protocol on port 9092)

3. **Custom Node.js scripts** using the `@azure/event-hubs` SDK

## Development

- Use `npm run watch` to automatically rebuild on file changes
- Use `npm run clean` to clean the dist folder
- The emulator containers will persist data between restarts

## Stopping

To stop the emulators:
```bash
docker-compose down
```

## Learn More

- [Azure Functions documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Event Hub emulator documentation](https://learn.microsoft.com/en-us/azure/event-hubs/test-locally-with-event-hub-emulator)
- [Azure Functions Event Hub trigger](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs)