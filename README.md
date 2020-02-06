[![CircleCI](https://circleci.com/gh/wizelineacademy/terraform-academy.svg?style=svg)](https://circleci.com/gh/wizelineacademy/terraform-academy)

# Terraform Academy

# Template Examples

https://github.com/gitpitch/the-template/blob/master/PITCHME.md

## Using Cloud9 (optional)

Use the following CloudFormation template to setup a Cloud9 environment in us-east-1 (N. Virginia), just click _Next_, _Next_, _Next_ and _Create Stack_:

[![Launch Stack](https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=TerraformAcademy&templateURL=https://terraform-wizeline-academy.s3.amazonaws.com/cloud9-cfn-template.yaml)

Go to your [Cloud9 service](https://console.aws.amazon.com/cloud9/home) inside the AWS console and click _Open IDE_ on your new environment called **TerraformAcademy**.

Once inside, use the terminal to install Terraform 0.12 with the following commands:

```
wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
unzip terraform_0.12.19_linux_amd64.zip && sudo mv terraform /usr/local/bin && rm -f terraform_0.12.19_linux_amd64.zip
terraform version
```

You can start working with the files located in the **terraform-academy** folder.
