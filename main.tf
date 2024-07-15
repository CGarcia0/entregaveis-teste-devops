module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  tags = {
    Environment = var.environment
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  instance_types = [var.instance_type]

  tags = {
    Environment = var.environment
    Name        = "eks-nodes"
  }
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-eks-shutdown-startup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_role_AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "shutdown_eks_nodes" {
  filename         = "C:\\Users\\chris\\Documents\\Python Scripts\\shutdown_eks_nodes.zip"
  function_name    = "shutdown_eks_nodes"
  role             = aws_iam_role.lambda_role.arn
  handler          = "shutdown_eks_nodes.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("C:\\Users\\chris\\Documents\\Python Scripts\\shutdown_eks_nodes.zip")
}

resource "aws_lambda_function" "startup_eks_nodes" {
  filename         = "C:\\Users\\chris\\Documents\\Python Scripts\\startup_eks_nodes.zip"
  function_name    = "startup_eks_nodes"
  role             = aws_iam_role.lambda_role.arn
  handler          = "startup_eks_nodes.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("C:\\Users\\chris\\Documents\\Python Scripts\\startup_eks_nodes.zip")
}

resource "aws_cloudwatch_event_rule" "shutdown_rule" {
  name                = "shutdown_eks_nodes_rule"
  description         = "Shutdown EKS nodes at 6 PM"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "shutdown_target" {
  rule = aws_cloudwatch_event_rule.shutdown_rule.name
  arn  = aws_lambda_function.shutdown_eks_nodes.arn
}

resource "aws_lambda_permission" "allow_shutdown_event" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shutdown_eks_nodes.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_rule.arn
}

resource "aws_cloudwatch_event_rule" "startup_rule" {
  name                = "startup_eks_nodes_rule"
  description         = "Startup EKS nodes at 9 AM"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "startup_target" {
  rule = aws_cloudwatch_event_rule.startup_rule.name
  arn  = aws_lambda_function.startup_eks_nodes.arn
}

resource "aws_lambda_permission" "allow_startup_event" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.startup_eks_nodes.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.startup_rule.arn
}
