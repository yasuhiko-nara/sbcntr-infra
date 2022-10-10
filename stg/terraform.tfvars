env = "stg"

# allowed_account_ids = [""]
vpc_cidr_block = "10.0.0.0/16"
azs = ["ap-northeast-1a",  "ap-northeast-1c"]
public_subnets = ["10.0.0.0/24", "10.0.1.0/24" ]
private_app_subnets = ["10.0.8.0/24", "10.0.9.0/24" ]
private_db_subnets = ["10.0.16.0/24", "10.0.17.0/24" ]

# Route53
root_domain_name = "wanchanmask.net"