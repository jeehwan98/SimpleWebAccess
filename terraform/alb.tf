/**
  Internet-facing ALB — receives HTTP on port 80 and forwards to EKS nodes
  ALB doesn't serve traffic itself, it just receives and forwards it
*/
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb" })
}

/**
  target_type = instance: ALB sends traffic to EKS node EC2 instances on NodePort 30080
  health check hits GET / on port 30080 every 30s — unhealthy after 3 failures, healthy again after 2 passes
*/
resource "aws_lb_target_group" "eks" {
  name        = "${local.name_prefix}-tg-eks"
  port        = 30080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = 30080
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-tg-eks" })
}

/**
  Auto-registers/deregisters EC2 nodes as they scale up or down
  Avoids the for_each + unknown values problem of data.aws_instances
*/
resource "aws_autoscaling_attachment" "eks_node_a" {
  autoscaling_group_name = aws_eks_node_group.a.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.eks.arn
}

resource "aws_autoscaling_attachment" "eks_node_b" {
  autoscaling_group_name = aws_eks_node_group.b.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.eks.arn
}

# all traffic on port 80 → EKS target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks.arn
  }
}
