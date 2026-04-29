/**
  Lambda function triggered by SQS — code lives in lambda/contact_saver.zip - and
  Terraform uploads it directly to AWS
*/
resource "aws_lambda_function" "contact_saver" {
  function_name = "${local.name_prefix}-contact-saver"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "index.handler"
  filename      = "${path.module}/../lambda/contact_saver.zip"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.contacts.bucket
    }
  }

  tags = local.common_tags
}

/**
  Wires SQS -> Lambda. AWS polls the queue on our behalf — no polling code needed.
  When a message arrives in SQS, AWS automatically invokes contact_saver with that message as the event payload.
*/
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.contact_saver.arn
  batch_size       = 1
}
