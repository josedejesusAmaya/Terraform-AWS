output "web-ip" {
  value = "${aws_instance.web.public_ip}"
}

output "web-dns" {
  value = "${aws_route53_record.dns-web.name}"
}
