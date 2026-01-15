$ErrorActionPreference = "Stop"

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host ""

# Get the outputs from the deployment
$outputs = azd env get-values --output json | ConvertFrom-Json
$EventHubsNamespace = $outputs.EVENTHUBS_CONNECTION__fullyQualifiedNamespace
$InputEventHubName = $outputs.INPUT_EVENTHUB_NAME
$OutputEventHubName = $outputs.OUTPUT_EVENTHUB_NAME

Write-Host "Event Hub Function App deployed successfully!" -ForegroundColor Yellow
Write-Host ""
Write-Host "System components:" -ForegroundColor Cyan
Write-Host "  - Event Hub Trigger Function: Processes messages from input Event Hub" -ForegroundColor White
Write-Host "  - Input Event Hub: $InputEventHubName" -ForegroundColor White
Write-Host "  - Output Event Hub: $OutputEventHubName" -ForegroundColor White
Write-Host "  - Event Hubs Namespace: $EventHubsNamespace" -ForegroundColor White
Write-Host ""
Write-Host "Function is now running in Azure!" -ForegroundColor Green
Write-Host ""
Write-Host "Function App Name: $($outputs.SERVICE_API_NAME)" -ForegroundColor Yellow

Write-Host "`nCreating/updating local.settings.json..." -ForegroundColor Yellow

@{
    "IsEncrypted" = "false";
    "Values" = @{
        "AzureWebJobsStorage" = "UseDevelopmentStorage=true";
        "FUNCTIONS_WORKER_RUNTIME" = "node";
        "EventHubConnection__fullyQualifiedNamespace" = "$EventHubsNamespace";
        "INPUT_EVENTHUB_NAME" = "$InputEventHubName";
        "OUTPUT_EVENTHUB_NAME" = "$OutputEventHubName";
    }
} | ConvertTo-Json | Out-File -FilePath ".\local.settings.json" -Encoding ascii -Force

Write-Host "local.settings.json has been created/updated successfully!" -ForegroundColor Green
