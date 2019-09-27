---?color=var(--color-light-gray-2)
@title[Lesson 02 - Scale Your App]

## Lesson 02 
#### Scale Your App

---
@title[Agenda]
@snap[west span-85]
### In this lesson we will learn...

@ul[spaced text-black]
- Count
- For expressions
- Dynamic nested blocks
- Conditional Operator
@ulend
@snapend

---
### Count
Sometimes you want to manage several similar objects, such as a fixed pool of compute instances. The count meta-argument accepts a whole number, and creates that many instances of the resource.

---
```
resource "aws_instance" "example" {
  count = 5
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  tags {
    Name = "example-${count.index}"
  }
}
```
@[2](This creates 5 different instances)
@[6](Use of index attribute)

---
@title[Agenda]
@snap[west span-85]
@ul[spaced text-black]
- Attributes of other resources: TYPE.NAME.ATTRIBUTE
- Attributes of a data source: data.TYPE.NAME.ATTRIBUTE
- Attributes of resources with count: TYPE.NAME[INDEX].ATTRIBUTE
@ulend
@snapend

---
```
output "instance_0_public_ip" {
  value = aws_instance.example[0].public_ip
}
```
@[2](Access attribute by index)

---
```
instance_0_public_ip = 34.228.239.144
```
@[1](Output of the 0th public IP)

---
### For expression
When working with lists and maps, it is common to need to apply a filter or transformation to each element in the collection and produce a new collection.

---
```
output "instance_private_ip_addresses" {
  value = {
    for instance in aws_instance.example:
    instance.id => instance.private_ip
  }
}
```
@[3-4](For expression)

---
```
instance_private_ip_addresses = {
  "i-06cd8e63ed2b1fc89" = "172.31.24.190"
  "i-079893979b62b69da" = "172.31.16.101"
  "i-07ac80c89eeb929b7" = "172.31.27.147"
  "i-0d0a78aa80900c44e" = "172.31.24.210"
  "i-0e8ba73084108fdf0" = "172.31.27.86"
}
```
@[1-7](Output values in new collection)

---
The map form of a for expression has a grouping mode where the map key is used to group items together into a list for each distinct key. This mode is activated by placing an ellipsis (...) after the value expression:

---
```
output "instances_by_availability_zone" {
  value = {
    for instance in aws_instance.example :
    instance.availability_zone => instance.id...
  }
}
```

---
```
instances_by_availability_zone = {
  "us-east-1d" = [
    "i-079893979b62b69da",
    "i-06cd8e63ed2b1fc89",
    "i-0e8ba73084108fdf0",
    "i-0d0a78aa80900c44e",
    "i-07ac80c89eeb929b7",
  ]
}
```
@[2-8](Group by availability_zone)

---
### Dynamic Nested blocks
Several resource types use nested configuration blocks to define repeatable portions of their configuration. Terraform has a construct for dynamically constructing a collection of nested configuration blocks.

---
```
resource "aws_autoscaling_group" "example" {
  # ...

  tag {
    key                 = "Name"
    value               = "example-asg-name"
    propagate_at_launch = false
  }

  tag {
    key                 = "Component"
    value               = "user-service"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }
}
```
@[4-8](Nested block)
@[10-14](Nested block)
@[16-20](Nested block)

---
```
locals {
  standard_tags = {
    Component   = "user-service"
    Environment = "production"
  }
}

resource "aws_autoscaling_group" "example" {
  # ...
  dynamic "tag" {
    for_each = local.standard_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
```
@[10-18](Generates a new block for each element in standard_tags)

---
### Conditional Operator
A conditional expression uses the value of a bool expression to select one of two values.

The syntax of a conditional expression is:

`condition ? true_val : false_val`

If condition is true then the result is true_val. If condition is false then the result is false_val.

---
```
variable "env" {
  default = "development"
}

resource "aws_instance" "prod_web" {
  count = var.env == "production" ? 1 : 0
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
}
```
@[6](Only creates resource when env is production)

---?color=var(--color-light-gray-2)
@title[What is Terraform?]
### Hands on work

---
![Architecture Diagram](slides/assets/img/lesson02-diagram.png)

---?code=slides/lesson2/solution/main_hard_code.tf&title=Terraform Main
@snap[span-90]
@[1-4](Provider)
@[6-14](Setup default vpc)
@[16-28](Load Balancer part 1)
@[29-46](Load Balancer part 2)
@[48-65](DNS record)
@[67-74](Security group)
@[75-88](Security group ingress)
@[89-95](Security group egress)
@[97-112](Launch configuration)
@[114-129](Autoscaling part 1)
@[130-142](Autoscaling part 2)
@[144-149](Output Load Balancer DNS)

---
![Architecture Diagram](slides/assets/img/lesson02-diagram.png)
