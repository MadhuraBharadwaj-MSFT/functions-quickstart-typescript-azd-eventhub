import { app, InvocationContext, output } from "@azure/functions";

interface EventMessage {
    id: string;
    message: string;
    timestamp: string;
}

const eventHubOutput = output.eventHub({
    connection: 'EventHubConnection',
    eventHubName: '%INPUT_EVENTHUB_NAME%'
});

export async function TimerTrigger(myTimer: any, context: InvocationContext): Promise<void> {
    context.log('⏰ Timer trigger function started');
    
    // Generate 3-5 test messages
    const messageCount = Math.floor(Math.random() * 3) + 3;
    const messages: EventMessage[] = [];
    
    for (let i = 0; i < messageCount; i++) {
        const message: EventMessage = {
            id: `msg-${Date.now()}-${i}`,
            message: `Auto-generated test message ${i + 1} at ${new Date().toISOString()}`,
            timestamp: new Date().toISOString()
        };
        messages.push(message);
        context.log(`📝 Generated message: ${message.id}`);
    }
    
    // Send messages to input Event Hub
    context.extraOutputs.set(eventHubOutput, messages);
    context.log(`✅ Sent ${messages.length} message(s) to input Event Hub`);
}

app.timer('TimerTrigger', {
    schedule: '0 */1 * * * *', // Every 1 minute
    handler: TimerTrigger,
    extraOutputs: [eventHubOutput]
});
