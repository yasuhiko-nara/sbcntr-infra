# module "describe_region_for_ec2" {
#   source     = "./modules/iam_role"
#   name       = "${var.env}-test"
#   identifier = "ec2.amazonaws.com"
#   policy     = data.aws_iam_policy_document.allow_describe_regions.json
# }

# data "aws_iam_policy_document" "allow_describe_regions" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:DescribeRegions"] #リージョン一覧を取得する
#     resources = ["*"]
#   }
# }
