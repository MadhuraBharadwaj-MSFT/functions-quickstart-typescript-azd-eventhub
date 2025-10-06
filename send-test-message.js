const { EventHubProducerClient } = require("@azure/event-hubs");

async function sendTestMessage() {
    // Same connection string as your Azure Function
    const connectionString = "Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;";
    const eventHubName = "eh1"; // Same Event Hub name as your function
    
    // Create a producer client
    const producer = new EventHubProducerClient(connectionString, eventHubName);
    
    try {
        console.log("🚀 Sending test message to Event Hub emulator...");
        
        // Create a batch of events
        const batch = await producer.createBatch();
        
        // Add events to the batch
        const eventData = {
            body: {
                message: "Hello from test script - 1!",
                timestamp: new Date().toISOString(),
                testNumber: Math.floor(Math.random() * 1000)
            }
        };
        
        batch.tryAdd(eventData);
        
        // Send the batch
        await producer.sendBatch(batch);
        
        console.log("✅ Message sent successfully!");
        console.log("📋 Message content:", JSON.stringify(eventData.body, null, 2));
        console.log("👀 Check your Azure Functions terminal for the trigger execution...");
        
    } catch (error) {
        console.error("❌ Error sending message:", error.message);
    } finally {
        await producer.close();
    }
}

// Send a test message
sendTestMessage().catch(console.error);