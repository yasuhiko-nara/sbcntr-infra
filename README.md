# 概要

Terraform で ECS 開発環境を構築するためのサンプルレポジトリです。

# Step1: aws-cli の設定

## クレデンシャルの設定（初回のみ）

```
$ aws configure --profile <your-environment-name>

AWS Access Key ID [None]: <アクセスキー>
AWS Secret Access Key [None]: <シークレットキー>
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

## コンテキストを変更(毎回)

```
$ export AWS_DEFAULT_PROFILE=<your-environment-name>

# 確認
$ aws configure list
```

# Step2：tfState 管理用のバケット作成

```
$ aws s3api create-bucket \
    --bucket <unique-bucket-name> \
    --create-bucket-configuration LocationConstraint=ap-northeast-1
$ aws s3api put-bucket-versioning \
    --bucket <unique-bucket-name> \ --versioning-configuration Status=Enabled
$ aws s3api put-bucket-encryption \
    --bucket sbcntr-infra-stg \ --server-side-encryption-configuration '{ "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}] }'
```

# StepN： ECS-Exec をつかってコンテナにアクセスする場合のコマンド

```
aws ecs execute-command --cluster <cluster-name> \
    --task <task-id> \
    --container <container-name> \
    --interactive \
    --command "/bin/sh"
```
