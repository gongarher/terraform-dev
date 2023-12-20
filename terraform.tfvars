region           = "eu-south-2"
ecr_name         = "test-ecr"
vpc_name         = "vpc_dev"
alb_name         = "Public-ALB-to-ecs"
alb_tg_name      = "alb-tg"
ecs_cluster_name = "ecs_cluster"
ecs_service_name = "ecs_service"
ecs_task_name      = "ecs_task"
ecs_container_name = "test_task_container"

tags = {
    env = "DEV"
}