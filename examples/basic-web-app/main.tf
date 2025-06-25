# Basic Web Application Example
# This example demonstrates deploying a simple web application using the ECS Fargate module

module "ecs_fargate" {
  source = "../../"

  cluster_name = "basic-web-app"

  services = {
    nginx = {
      image              = "nginx:latest"
      cpu                = 256
      memory             = 512
      desired_count      = 2
      subnet_ids         = var.private_subnet_ids
      security_group_ids = [aws_security_group.ecs_tasks.id]
      execution_role_arn = aws_iam_role.ecs_execution_role.arn
      assign_public_ip   = false

      container_ports = [
        {
          container_port = 80
          protocol       = "tcp"
        }
      ]

      environment_variables = [
        {
          name  = "NGINX_PORT"
          value = "80"
        }
      ]

      target_groups = {
        web = {
          port           = 80
          protocol       = "HTTP"
          vpc_id         = var.vpc_id
          container_port = 80
          health_check = {
            path                = "/"
            healthy_threshold   = 2
            unhealthy_threshold = 2
            timeout             = 5
            interval            = 30
            matcher             = "200"
          }
        }
      }

      health_check = {
        command      = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      }
    }
  }

  tags = {
    Environment = "development"
    Project     = "basic-web-app"
    ManagedBy   = "terraform"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs-tasks-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-tasks-sg"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "alb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "basic-web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids

  tags = {
    Name = "basic-web-app-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs_fargate.target_group_arns["nginx-web"]
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}