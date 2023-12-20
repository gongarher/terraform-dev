# ECS Cluster
resource "aws_ecs_cluster" "default" {
  name = var.ecs_cluster_name

  tags = merge({Name = var.ecs_cluster_name}, var.tags)
}

# ECS Service
resource "aws_ecs_service" "service" {
  depends_on = [module.vpc, aws_lb_target_group.service_target_group]
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  desired_count   = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  # manage task definition (CI/CD) via Github actions
  task_definition = aws_ecs_task_definition.task.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.service_target_group.arn
    container_name   = var.ecs_container_name
    container_port   = 80
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  # Ignore task_definition changes
  lifecycle {
   ignore_changes = [task_definition]
  }

  tags = merge({Name = var.ecs_service_name}, var.tags)
}

# SG for ECS Service (and Tasks)
# 443 port needed in order to connect to ECR!!!
resource "aws_security_group" "ecs_service_sg" {
  name        = "allow_http_and_https"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow ingress HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({Name = "allow_http"}, var.tags)
}

## ECS Task Definition (will be updated via Github Actions)
resource "aws_ecs_task_definition" "task" {
  family                   = var.ecs_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # needed: FARGATE
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name         = var.ecs_container_name
      image        = "${aws_ecr_repository.ecr.repository_url}:v1.1.3"
      cpu          = 1024
      memory       = 2048
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = merge({Name = var.ecs_task_name}, var.tags)
}

# NEED to create execution_role (FARGATE TASKS)
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECS_TASK_EXECUTION_ROLE"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json

  tags = merge({Name = "ECS_TASK_EXECUTION_ROLE"}, var.tags)
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

