---?color=var(--color-light-gray-2)

The set of files used to describe infrastructure in Terraform is simply known as a Terraform configuration. (*.tf)

---
@title[Terraform Commands]
### Terraform Commands

---
@title[What is Terraform?]
@snap[west span-85]
### Terraform core commands
@ul[spaced text-black]
- ``` bash
  init
```
- ``` bash plan```
- apply.
- destroy.
- fmt.
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
