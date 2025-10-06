# Azure Functions TypeScript Event Hub Trigger Quickstart

This repository contains a TypeScript Azure Functions project configured to work with Event Hub triggers using the local Event Hub emulator.

## Prerequisites

- [Node.js](https://nodejs.org/) (v18 or later)
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

Once everything is running, you can test the Event Hub trigger by sending messages to the emulator. The function will process messages sent to the `eh1` Event Hub.

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