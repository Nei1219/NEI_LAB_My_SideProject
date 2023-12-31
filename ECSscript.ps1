# 802783396857
# aws ecr get-login-password --region eu-west-3 --profile 802783396857 | docker login --username AWS --password-stdin 802783396857.dkr.ecr.eu-west-3.amazonaws.com
Import-Module -Name AWSPowerShell

docker build -t app01 .
docker tag app01:latest 802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest
# docker tag myapp1:latest 802783396857.dkr.ecr.eu-west-3.amazonaws.com/myapp1:f

docker run -d -p 8081:3000 --name web01 802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest

aws ecr get-login-password --region eu-west-1 --profile 8027 | docker login --username AWS --password-stdin 802783396857.dkr.ecr.eu-west-1.amazonaws.com

docker push 802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest



$port = 3000
$name = "cicd-myapp"
$image = "802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest"

# Define Container
$PortMappings = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.PortMapping]"
$PortMappings.Add($(New-Object -TypeName "Amazon.ECS.Model.PortMapping" -Property @{ HostPort = $port; ContainerPort = $port; Protocol = [Amazon.ECS.TransportProtocol]::Tcp }))
$PortMappings

$EnvironmentVariables = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.KeyValuePair]"
# $EnvironmentVariables.Add($(New-Object -TypeName "Amazon.ECS.Model.KeyValuePair" -Property @{ Name="OCTO_COLOR"; Value=$OctopusParameters["Color"]}))
# $EnvironmentVariables.Add($(New-Object -TypeName "Amazon.ECS.Model.KeyValuePair" -Property @{ Name="OCTO_MSG"; Value=$OctopusParameters["Message"]}))

Write-Host "Adding Container Definition for" $image
$ContainerDefinitions = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.ContainerDefinition]"
$ContainerDefinitions.Add($(New-Object -TypeName "Amazon.ECS.Model.ContainerDefinition" -Property @{ `
                Name         = $name; `
                Image        = $image; `
                PortMappings = $PortMappings; `
                Environment  = $EnvironmentVariables
            Memory           = 256
        }))

# Create Task
$Region = "eu-west-1"
$TaskName = "cicd-task"
$ExecutionRole = $(Get-IAMRole -profilename 8027 -RoleName "ecsTaskExecutionROle").Arn
Write-Host "Creating New Task Definition $TaskName"
$TaskDefinition = Register-ECSTaskDefinition -profilename 8027 `
    -ContainerDefinition $ContainerDefinitions `
    -Cpu 256 `
    -Family $TaskName `
    -TaskRoleArn $ExecutionRole `
    -ExecutionRoleArn $ExecutionRole `
    -Memory 512 `
    -NetworkMode awsvpc `
    -Region $Region `
    -RequiresCompatibility "FARGATE"

Write-Host "Created Task Definition $($TaskDefinition.TaskDefinition)"
Write-Verbose $TaskDefinition | ConvertTo-Json 


# if no service, create new ecs service through aws-cli cloudformation
aws cloudformation deploy --template-file ./web3.json --stack-name cicd-stack --parameter-overrides InstanceTypeParameter=t2.micro --profile 8027 --region eu-west-1

# Get last task
$lastECSTaskDefinitions = Get-ECSTaskDefinitions -ProfileName 8027 -Region eu-west-1 | Select-Object -Last 1 
$lastECSTaskDefinitions
$LastTaskDefinition = Get-ECSTaskDefinitionDetail -ProfileName 8027 -Region eu-west-1 -TaskDefinition cicd-task:1

# Update Service
$ClusterName = "cicd-cluster"
$ServiceName = "cicd-service"
Write-Host "Updating Service $ServiceName"
$ServiceUpdate = Update-ECSService -profilename 8027 -Region $Region `
    -Cluster $ClusterName `
    -ForceNewDeployment $true `
    -Service $ServiceName `
    -TaskDefinition $LastTaskDefinition.TaskDefinition.TaskDefinitionArn `
    -DesiredCount 2 `
    -DeploymentConfiguration_MaximumPercent 200 `
    -DeploymentConfiguration_MinimumHealthyPercent 100

Write-Host "Updated Service $($ServiceUpdate.ServiceArn)"
$ServiceUpdate | ConvertTo-Json