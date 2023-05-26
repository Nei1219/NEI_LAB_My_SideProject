# Get last task
$lastECSTaskDefinitions = Get-ECSTaskDefinitions -Region eu-west-1 | Select-Object -Last 1 
$lastECSTaskDefinitions
$LastTaskDefinition = Get-ECSTaskDefinitionDetail -Region eu-west-1 -TaskDefinition cicd-task1 | Select-Object -Last 1 

# Update Service
$ClusterName = "cicd-cluster"
$ServiceName = "cicd-service1"
Write-Host "Updating Service $ServiceName"
$ServiceUpdate = Update-ECSService -Region $Region `
    -Cluster $ClusterName `
    -ForceNewDeployment $true `
    -Service $ServiceName `
    -TaskDefinition $LastTaskDefinition.TaskDefinition.TaskDefinitionArn `
    -DesiredCount 2 `
    -DeploymentConfiguration_MaximumPercent 200 `
    -DeploymentConfiguration_MinimumHealthyPercent 100

Write-Host "Updated Service $($ServiceUpdate.ServiceArn)"
$ServiceUpdate | ConvertTo-Json