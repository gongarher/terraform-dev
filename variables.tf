variable "region" {
    description = "AWS Region to deploy to"
}

variable "tags" {
    description = "Common tags"
    default = {}
}

variable "ecr_name" {
    description = "Name of the Elastic Container Registry"
}

variable "vpc_name" {
    description = "Name of the new VPC where ECS and ALB are goint to be deployed"
}