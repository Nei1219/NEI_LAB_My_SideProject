Install-Module AWSPowerShell -Force
Import-Module -Name AWSPowerShell
# Get last task
$lastECSTaskDefinitions = Get-ECSTaskDefinitions  | Select-Object -Last 1 
$lastECSTaskDefinitions
$LastTaskDefinition = Get-ECSTaskDefinitionDetail -TaskDefinition cicd-task1 | Select-Object -Last 1 
# Update Service
$ClusterName = "cicd-cluster"
$ServiceName = "cicd-service1"
Write-Host "Updating Service $ServiceName"
$ServiceUpdate = Update-ECSService
    -Cluster $ClusterName `
    -ForceNewDeployment $true `
    -Service $ServiceName `
    -TaskDefinition $LastTaskDefinition.TaskDefinition.TaskDefinitionArn `
    -DesiredCount 2 `
    -DeploymentConfiguration_MaximumPercent 200 `
    -DeploymentConfiguration_MinimumHealthyPercent 100

Write-Host "Updated Service $($ServiceUpdate.ServiceArn)"
$ServiceUpdate | ConvertTo-Json