# 創建 ECS Cluster
$clusterName = "webnei-cluster"
New-ECSCluster -ClusterName $clusterName

# 創建 Task Definition
$taskDefinition = @{
    family = "webnei-task"
    containerDefinitions = @(
        @{
            name = "webnei-container"
            image = "802783396857.dkr.ecr.eu-west-1.amazonaws.com/nei_repository:latest"
            portMappings = @(
                @{
                    containerPort = 3000
                    protocol = "tcp"
                }
            )
        }
    )
} | ConvertTo-Json
$taskDefinitionArn = New-ECSTaskDefinition -TaskDefinition $taskDefinition | Select-Object -ExpandProperty TaskDefinitionArn