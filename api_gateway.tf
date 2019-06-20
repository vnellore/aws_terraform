resource "aws_api_gateway_rest_api" "MyWebAPIGateway" {
  name        = "MyWebAPIGateway"
  description = "LambdaWebAPI API Gateway"

  endpoint_configuration = {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.MyWebAPIGateway.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.LambdaWebAPI.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.MyWebAPIGateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.LambdaWebAPI.invoke_arn}"
}

resource "aws_api_gateway_deployment" "staging_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  stage_name  = "staging"
}

resource "aws_api_gateway_deployment" "prod_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.MyWebAPIGateway.id}"
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.LambdaWebAPI.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.MyWebAPIGateway.execution_arn}/*/*"
}

output "webapi_staging_url" {
  value = "${aws_api_gateway_deployment.staging_deployment.invoke_url}"
}

output "webapi_prod_url" {
  value = "${aws_api_gateway_deployment.prod_deployment.invoke_url}"
}

output "aws_api_gateway_rest_api_arn" {
  value = "${aws_api_gateway_rest_api.MyWebAPIGateway.execution_arn}"
}
