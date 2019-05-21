---?color=var(--color-light-gray-2)
@title[Lesson 02 - Scale Your App]

## Lesson 02 
#### Scale Your App

---
@title[Agenda]
@snap[west span-85]
### In this lesson we will learn...

@ul[spaced text-black]
- ifs and loops
- terraform interpolations
- tips and tricks
@ulend
@snapend
---
```
# This is just pseudo code. It won't actually work in Terraform.
for i = 0; i < 3; i++ {
  resource "aws_instance" "example" {
    ami = "ami-2d39803a"
    instance_type = "t2.micro"
  }  
}
```
---
```
resource "aws_instance" "example" {
  count = 3
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
}
```
@[1-5](example)
---
### Interpolations
Embedded within strings in Terraform, whether you're using the Terraform syntax or JSON syntax, you can interpolate other values. These interpolations are wrapped in ${}, such as ${var.foo}.
---
@title[Agenda]
@snap[west span-85]
@ul[spaced text-black]
- Attributes of other resources: TYPE.NAME.ATTRIBUTE
- Attributes of a data source: data.TYPE.NAME.ATTRIBUTE
- conditionals (CONDITION ? TRUEVAL : FALSEVAL)
@ulend
@snapend
---
@title[Agenda]
@snap[west span-85]
### built in functions:
@ul[spaced text-black]
- element(list, index)
- file(path)
- length(list)
- list(items, ...)
@ulend
@snapend
---
@snap[west span-85]
### Examples
signum(integer) - Returns -1 for negative numbers, 0 for 0 and 1 for positive numbers. This function is useful when you need to set a value for the first resource and a different value for the rest of the resources. 
@snapend
---
```
element(split(",", var.r53_failover_policy), signum(count.index)) 
```
@[1](where the 0th index points to PRIMARY and 1st to FAILOVER)
---
```
resource "aws_instance" "web" {
  subnet = "${var.env == "production" ? var.prod_subnet : var.dev_subnet}"
}
```
---
```
resource "aws_instance" "example" {
  count = 3
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  availability_zone = "${element(var.azs, count.index)}"
  tags {
    Name = "example-${count.index}"
  }
}
```
@[2](number of times)
@[5](use of index for interpolation)
---
```
output "public_ips" {
  value = ["${aws_instance.example.*.public_ip}"]
}
```
@[1-3](example of how to output when you have a list)
---
```
resource "aws_eip" "example" {
  count = 15
  instance = "${element(aws_instance.example.*.id, count.index)}"
}
```
@[1-4](example of for using interpolation)
---
```
resource "aws_eip" "example" {
  count = "${var.create_eip}"
  instance = "${aws_instance.example.id}"
}

resource "aws_route53_record" "example" {
  count = "${1 - var.create_eip}"
  zone_id = "A1B2CDEF3GH4IJ"
  name = "foo.example.com"
  type = "A"
  ttl = 300
  records = ["${aws_instance.example.public_ip}"]
}
```
@[1-4](if create_eip)
@[6-13](else)
---?color=var(--color-light-gray-2)
@title[What is Terraform?]
### Hands on work

---?code=slides/lesson2/solution/main_hard_code.tf&title=Terraform Main
@snap[span-90]
@[1-11](provider)
@[17-22](setup default vpc)
@[27-39](Load Balancer)
@[40-53](Load Balancer 2)
@[59-70](dns record)
@[75-78](security group)
@[80-85](security group ingress)
@[94-99](security group egress)
@[105-117](launch configuration)
@[122-132](Autoscaling part 2)
@[133-144](Autoscaling metrics)

