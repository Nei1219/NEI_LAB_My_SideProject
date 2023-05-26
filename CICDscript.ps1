Install-Module AWSPowerShell -Force
Import-Module -Name AWSPowerShell

$port = 3000
$name = "cicd-myapp1"
$image = "802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest"

# Define Container
$PortMappings = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.PortMapping]"
$PortMappings.Add($(New-Object -TypeName "Amazon.ECS.Model.PortMapping" -Property @{ HostPort = $port; ContainerPort = $port; Protocol = [Amazon.ECS.TransportProtocol]::Tcp }))
$PortMappings

$EnvironmentVariables = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.KeyValuePair]"

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
$TaskName = "cicd-task1"
$ExecutionRole = $(Get-IAMRole -RoleName "ecsTaskExecutionROle").Arn
Write-Host "Creating New Task Definition $TaskName"
$TaskDefinition = Register-ECSTaskDefinition `
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
# aws cloudformation deploy --template-file ./web3.json --stack-name cicd-stack01 --parameter-overrides InstanceTypeParameter=t2.micro --region eu-west-1
