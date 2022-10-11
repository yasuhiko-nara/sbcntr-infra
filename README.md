# Repos

- infra: https://github.com/yasuhiko-nara/sbcntr-infra
- frontend: https://github.com/yasuhiko-nara/sbcntr-frontend
- backend: https://github.com/uma-arai/sbcntr-frontend
- 実践 Terraform: https://github.com/tmknom/example-pragmatic-terraform

# create tfstate s3 bucket

```
aws s3api create-bucket --bucket <unique-bucket-name> --create-bucket-configuration LocationConstraint=ap-northeast-1
aws s3api put-bucket-versioning --bucket <unique-bucket-name> --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket sbcntr-infra-stg --server-side-encryption-configuration '{ "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}] }'

```
