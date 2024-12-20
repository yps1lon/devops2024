variable "alarm_email" {
  type = string
}

resource "aws_iam_role" "lambda_role" {
  name = "LambdaSqsExecutionRole_v2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "LambdaSqsPolicy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.lambda_bucket.arn}/kn4/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.lambda_sqs_queue.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sqs_queue" "lambda_sqs_queue" {
  name = "image-gen-4"
}

resource "aws_lambda_function" "image_generation_lambda" {
  function_name = "ImageGenerationLambdaV2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_sqs.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_sqs.zip"
  environment {
    variables = {
      BUCKET_NAME = data.aws_s3_bucket.lambda_bucket.bucket
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.lambda_sqs_queue.arn
  function_name    = aws_lambda_function.image_generation_lambda.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_sns_topic" "cloudwatch_alarm_topic" {
  name = "cloudwatch-alarm-topic"
}

resource "aws_sns_topic_subscription" "cloudwatch_alarm_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_age_alarm" {
  alarm_name          = "SQSApproximateAgeOfOldestMessage"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  statistic           = "Maximum"
  dimensions = {
    QueueName = aws_sqs_queue.lambda_sqs_queue.name
  }
  period              = 60
  evaluation_periods  = 1
  threshold           = 300
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_topic.arn]
}
