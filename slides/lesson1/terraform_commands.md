---?color=var(--color-light-gray-2)

The set of files used to describe infrastructure in Terraform is simply known as a Terraform configuration. (*.tf)

---
@title[Terraform Commands]
### Terraform Commands

---
@title[Terraform core commands]
@snap[west span-85]
### Terraform core commands

@title[init]

@title[apply]

@title[destroy]

@title[fmt]

@title[validate]


```bash
  terraform init

  terraform apply

  terraform destroy

  terraform fmt

  terraform validate
```

@[1-2](init)
@[3-4](apply)
@[5-6](destroy)
@[7-8](fmt)
@[9-10](validate)

@snapend

---
@title[Terraform Resource Blocks]
### Terraform Resource Blocks

---
@title[provider]
@title[resource]
```
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-00c03f7f7f2ec15c3"
  instance_type = "t2.micro"
}
```
@[1-3](provider)
@[5-8](resource)
