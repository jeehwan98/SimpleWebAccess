/** 
  values would be printed after terraform apply
  these values are used to configure our docker push commands and verify the deployment
*/

output "sqs_queue_url" {
  description = "SQS queue URL — set as SQS_QUEUE_URL env var on the backend"
  value       = aws_sqs_queue.main.url
}

output "s3_bucket_name" {
  description = "S3 bucket name — set as S3_BUCKET env var on the backend"
  value       = aws_s3_bucket.contacts.bucket
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.contact_saver.function_name
}

output "ecr_frontend_url" {
  description = "Frontend ECR URL — used in docker push commands"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  description = "Backend ECR URL — used in docker push commands"
  value       = aws_ecr_repository.backend.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_kubeconfig_command" {
  description = "Run this after terraform apply to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "app_url" {
  description = "App URL"
  value       = "http://www.simplewebaccess.com"
}
