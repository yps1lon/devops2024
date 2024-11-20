terraform {
  required_version = ">= 1.9.0"
  
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "kn4/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_s3_bucket" "lambda_bucket" {
  bucket = "pgr301-couch-explorers"
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
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

resource "aws_sqs_queue" "lambda_sqs_queue" {
  name = "image-gen-4"
  visibility_timeout_seconds = 60
}

resource "aws_lambda_function" "image_generation_lambda" {
  function_name    = "ImageGenerationLambdaV2"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60
  memory_size      = 512
  environment {
    variables = {
      BUCKET_NAME = data.aws_s3_bucket.lambda_bucket.bucket
    }
  }
  filename         = "lambda_sqs.zip"
  source_code_hash = filebase64sha256("lambda_sqs.zip")
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
  endpoint  = "bema015@egms.no"  
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