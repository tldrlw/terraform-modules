data "aws_caller_identity" "current" {}
# ^ not being used anywhere as of 9/18/24
# The attribute `${data.aws_caller_identity.current.account_id}` will be current account number.
