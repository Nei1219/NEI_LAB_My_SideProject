# Define Container
$PortMappings = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.PortMapping]"
$PortMappings.Add($(New-Object -TypeName "Amazon.ECS.Model.PortMapping" -Property @{ HostPort = 3000; ContainerPort = 3000; Protocol = [Amazon.ECS.TransportProtocol]::Tcp }))

# $EnvironmentVariables = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.KeyValuePair]"
# $EnvironmentVariables.Add($(New-Object -TypeName "Amazon.ECS.Model.KeyValuePair" -Property @{ Name = "OCTO_COLOR"; Value = "RED" }))
# $EnvironmentVariables.Add($(New-Object -TypeName "Amazon.ECS.Model.KeyValuePair" -Property @{ Name="OCTO_MSG"; Value=$OctopusParameters["Message"]}))

# Write-Host "Adding Container Definition for" $OctopusParameters["Octopus.Action.Package[web].Image"]
$ContainerDefinitions = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.ContainerDefinition]"
$ContainerDefinitions.Add($(New-Object -TypeName "Amazon.ECS.Model.ContainerDefinition" -Property @{
            Name         = "container01"
            Image        = "802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest"
            PortMappings = $PortMappings
            Environment  = $EnvironmentVariables
            CPU          = 256
            Memory       = 512
        }))


# Create Task
$Region = "eu-west-1"
$TaskName = "task01"
$ExecutionRole = $(Get-IAMRole -RoleName "ecsTaskExecutionRole" -ProfileName 8027).Arn
Write-Host "Creating New Task Definition $TaskName"
$TaskDefinition = Register-ECSTaskDefinition -ProfileName 8027 -Region $Region -ContainerDefinition $ContainerDefinitions -Cpu 256 -Family $TaskName -ExecutionRoleArn $ExecutionRole -Memory 512 -NetworkMode awsvpc -RequiresCompatibility "FARGATE"


# Update Service
$ClusterName = "webapp-cluster"
$ServiceName = "service01"
# Write-Host "Updating Service $ServiceName"
$ServiceUpdate = Update-ECSService -ProfileName 8027 -Region eu-west-1 -Cluster $ClusterName -ForceNewDeployment $true -Service $ServiceName -TaskDefinition $TaskDefinition.TaskDefinition.TaskDefinitionArn -DesiredCount 3 -DeploymentConfiguration_MaximumPercent 200 -DeploymentConfiguration_MinimumHealthyPercent 100
if (!$?) {
    Write-Error "Failed to register new task definition"
    Exit 0
}
# Write-Host "Updated Service $($ServiceUpdate.ServiceArn)"
# Write-Verbose $($ServiceUpdate | ConvertTo-Json)