resource "aws_lambda_function" "LambdaWebAPI" {
  function_name = "LambdaMyWebAPI"
  description   = "Lambda function for Web API"
  s3_bucket     = "${var.my_lambda_source_bucket_name}"
  s3_key        = "${var.env}/LambdaMyWebAPI.zip"
  memory_size   = 256
  timeout       = 40
  publish       = true
  handler       = "LambdaMyWebAPI::LambdaMyWebAPI.LambdaEntryPoint::FunctionHandlerAsync"
  runtime       = "dotnetcore2.1"
  role          = "${var.lambda_webapi_role}"

  vpc_config {
    subnet_ids         = "${var.lambda_webapi_vpc_subnets}"
    security_group_ids = "${var.lambda_webapi_vpc_sec_groups}"
  }

  environment {
    variables = {
      connectionString = "${var.connectionString}"
    }
  }

  tags = {
    name               = "LambdaMyWebAPI"
    applicationRole    = "lambda function"
    confidentiality    = "protected"
    owner              = "Support Team"
    environment        = "${var.env}"
    applicationID      = "Terraform Test App"
    compliancerelevant = "No"
    businessowner      = "Business Team"
  }
}
