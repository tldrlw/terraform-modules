data "aws_iam_policy_document" "private_apig" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"] # Allow all principals (can be adjusted as needed)
    }
    actions = ["execute-api:Invoke"]
    resources = [
      "arn:aws:execute-api:${var.REGION}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private.id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.api_gateway.id]
    }
  }
}

resource "aws_api_gateway_rest_api_policy" "private" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  policy      = data.aws_iam_policy_document.private_apig.json
}

# private REST APIs in API Gateway require a resource policy to define who or what can access the API. This is a security measure to ensure private APIs are explicitly restricted to allowed principals or IP addresses.
