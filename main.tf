
#############################################################################
# IAM Policy Document for Assume Role (Trust Relationship)
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }
  }
}

# Combined IAM Role
resource "aws_iam_role" "combined_role" {
  name               = "combined_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# # Attach AWS Managed Policy for S3 Full Access
# resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
#   role       = aws_iam_role.combined_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

# # Attach AWS Managed Policy for API Gateway Access
# resource "aws_iam_role_policy_attachment" "api_gateway_access_attachment" {
#   role       = aws_iam_role.combined_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
# }

# # Attach AWS Managed Policy for Lambda Basic Execution
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
#   role       = aws_iam_role.combined_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# Custom Inline Policy for Additional Permissions
data "aws_iam_policy_document" "custom_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
      "lambda:InvokeFunction",
      "apigateway:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "custom_policy" {
  name        = "custom_policy_for_combined_role"
  description = "Custom inline policy for additional permissions"
  policy      = data.aws_iam_policy_document.custom_policy.json
}

# Attach Custom Policy to Combined Role
resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  role       = aws_iam_role.combined_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}

