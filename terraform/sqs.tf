resource "aws_sqs_queue" "main" {
  name                       = "${local.name_prefix}-queue"
  message_retention_seconds  = 86400 # 1 day
  visibility_timeout_seconds = 30
  tags                       = local.common_tags
}
