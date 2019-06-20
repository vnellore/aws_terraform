# aws_terraform
AWS Terraform scripts to build the following components
* S3 static website
* CloudFront configuration with HTTPS
* Web Application Firewall (WAF) - Regional and Global
* API Gateway
* Lambda

Terraform Language Version 0.11

Commands
*Plan*
```
$ terraform plan -var-file="testing.tfvars"
```
*Apply*
```
$ terraform apply -var-file="testing.tfvars"
```
