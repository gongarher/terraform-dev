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

variable "tags" {
    description = "Common tags"
    default = {}
}