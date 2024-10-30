# The attribute `${data.aws_region.current.name}` will be current region
data "aws_region" "current" {}

data "aws_iam_user" "initiating_user" {
  user_name = "local"
}
