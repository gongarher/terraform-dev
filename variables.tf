variable "region" {
    description = "AWS Region to deploy to"
}

##### ECR #####
variable "ecr_name" {
    description = "Name of the Elastic Container Registry"
}

##### VPC #####
variable "vpc_name" {
    description = "Name of the new VPC where ECS and ALB are goint to be deployed"
}

##### ALB #####
variable "alb_name" {
    description = "Name of the ALB attached to ECS service"
}
variable "alb_tg_name" {
    description = "Name of the target group attached to ALB"
}

##### ECS #####
variable "ecs_cluster_name" {
    description = "Name of the ECS cluster"
}
variable "ecs_service_name" {
    description = "Name of the ECS service"
}
variable "ecs_task_name" {
    description = "Name of the ECS task"
}
variable "ecs_container_name" {
    description = "Name of the ECS task container"
}

variable "tags" {
    description = "Common tags"
    default = {}
}