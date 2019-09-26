---?color=var(--color-light-gray-2)

The set of files used to describe infrastructure in Terraform is simply known as a Terraform configuration. (*.tf)

---
@title[Terraform Commands]
### Terraform Commands

---
@title[Terraform core commands]
@snap[west span-85]
### Terraform core commands
@ul[spaced text-black]
- init
```bash
  terraform init
```

- apply
```bash
  terraform apply
```

- destroy
```bash
  terraform destroy
```

- fmt
```bash
  terraform fmt
```

- validate
```bash
  terraform validate
```
@ulend
@snapend

---
@title[Terraform Resource Blocks]
### Terraform Resource Blocks

---
@title[provider]
@title[resource]
```
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = "ami-02bcbb802e03574ba"
  instance_type = "m4.large"
}
```
@[1-3](provider)
@[5-8](resource)
