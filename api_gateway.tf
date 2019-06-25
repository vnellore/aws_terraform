resource "aws_api_gateway_rest_api" "MyAPIGateway" {
  name        = "MyAPIGateway"
  description = "My API Gateway"

  endpoint_configuration = {
    types = ["EDGE"]
  }
}

/// configure {proxy+}
resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  path_part   = "{proxy+}"
}

////
resource "aws_api_gateway_method" "proxy_any_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "any_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_any_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_options_method.http_method}"
  status_code = "200"

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_options_method.http_method}"

  type = "MOCK"

  request_templates {
    "application/json" = "{ \"statusCode\": 200   }"
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.options_200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration" "any_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_any_method.http_method}"

  integration_http_method = "POST"                                           //Lambda function can only be invoked with POST
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.LambdaWebAPI.invoke_arn}"
}

resource "aws_api_gateway_integration_response" "any_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_any_method.http_method}"
  status_code = "${aws_api_gateway_method_response.any_200.status_code}"
}

/// configure root options
resource "aws_api_gateway_method" "proxy_root_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_options_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_options_method.http_method}"
  status_code = "200"

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "root_options_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_options_method.http_method}"

  type = "MOCK"

  request_templates {
    "application/json" = "{ \"statusCode\": 200   }"
  }
}

resource "aws_api_gateway_integration_response" "root_options_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.root_options_200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

/// root any method configuration
resource "aws_api_gateway_method" "proxy_root_any_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_any_200" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_any_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration" "root_any_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_any_method.http_method}"

  integration_http_method = "POST"                                           //Lambda function can only be invoked with POST
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.LambdaWebAPI.invoke_arn}"
}

resource "aws_api_gateway_integration_response" "root_any_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  resource_id = "${aws_api_gateway_rest_api.MyAPIGateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root_any_method.http_method}"
  status_code = "${aws_api_gateway_method_response.root_any_200.status_code}"
}

///
resource "aws_api_gateway_deployment" "prod_deployment" {
  depends_on = [
    "aws_api_gateway_integration.any_integration",
    "aws_api_gateway_integration.root_any_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.MyAPIGateway.id}"
  stage_name  = "prod"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowWebAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.LambdaWebAPI.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.MyAPIGateway.execution_arn}/*/*"
}

output "webapi_prod_url" {
  value = "${aws_api_gateway_deployment.prod_deployment.invoke_url}"
}

output "aws_api_gateway_rest_api_arn" {
  value = "${aws_api_gateway_rest_api.MyAPIGateway.execution_arn}"
}
