#################################
# S3 Buckets
#################################
resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-raw-12345"
}

resource "aws_s3_bucket" "curated" {
  bucket = "${var.project_name}-curated-12345"
}

resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-athena-results-12345"
}

#################################
# IAM Roles
#################################

# Glue Role
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#################################
# Glue Job
#################################
resource "aws_glue_job" "retail_etl" {
  name     = "${var.project_name}-glue-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.raw.bucket}/scripts/etl.py"
    python_version  = "3"
  }

  glue_version = "4.0"
  max_capacity = 2

  default_arguments = {
    "--job-language"  = "python"
    "--enable-metrics" = "true"
  }
}

#################################
# Lambda Function (Glue Trigger)
#################################
resource "aws_lambda_function" "etl_trigger" {
  function_name = "${var.project_name}-trigger"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.10"
  timeout       = 60

  filename = "lambda.zip" # you provide this

  environment {
    variables = {
      GLUE_JOB_NAME = aws_glue_job.retail_etl.name
    }
  }
}

#################################
# S3 → Lambda Notification
#################################
resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.etl_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.etl_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

#################################
# SNS + EventBridge Monitoring
#################################
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "glue_status" {
  name = "${var.project_name}-glue-status"

  event_pattern = jsonencode({
    source      = ["aws.glue"]
    detail-type = ["Glue Job State Change"]
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule = aws_cloudwatch_event_rule.glue_status.name
  arn  = aws_sns_topic.alerts.arn
}

#################################
# Athena + Glue Catalog
#################################
resource "aws_glue_catalog_database" "analytics" {
  name = "retail_analytics"
}

resource "aws_athena_workgroup" "analytics" {
  name = "${var.project_name}-wg"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }
  }
}