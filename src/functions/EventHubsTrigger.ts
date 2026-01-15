import { app, InvocationContext, output } from "@azure/functions";

interface EventMessage {
    id: string;
    message: string;
    timestamp: string;
}

const eventHubOutput = output.eventHub({
    connection: 'EventHubConnection',
    eventHubName: '%OUTPUT_EVENTHUB_NAME%'
});

export async function EventHubsTrigger(messages: unknown[], context: InvocationContext): Promise<void> {
    context.log(`🔄 Event hub function processing ${messages.length} message(s)`);
    
    const processedMessages: EventMessage[] = [];
    
    for (const message of messages) {
        try {
            // Parse the incoming message
            const eventData = typeof message === 'string' ? JSON.parse(message) : message;
            context.log('📨 Processing event:', eventData);
            
            // Create processed message with additional metadata
            const processedMessage: EventMessage = {
                id: eventData.id || crypto.randomUUID(),
                message: eventData.message || JSON.stringify(eventData),
                timestamp: new Date().toISOString()
            };
            
            processedMessages.push(processedMessage);
            context.log('✨ Message processed:', processedMessage);
            
        } catch (error) {
            context.error(`❌ Error processing message: ${error}`);
        }
    }
    
    // Send processed messages to output Event Hub
    if (processedMessages.length > 0) {
        context.extraOutputs.set(eventHubOutput, processedMessages);
        context.log(`📤 Sent ${processedMessages.length} message(s) to output Event Hub`);
    }
}

app.eventHub('EventHubsTrigger', {
    connection: 'EventHubConnection',
    eventHubName: '%INPUT_EVENTHUB_NAME%',
    cardinality: 'many',
    extraOutputs: [eventHubOutput],
    handler: EventHubsTrigger
});
