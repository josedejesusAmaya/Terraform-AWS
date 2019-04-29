resource "aws_iam_access_key" "default" {
  count = "${var.users}"

  user    = "${element(aws_iam_user.default.*.name, count.index)}"
  pgp_key = "keybase:${var.pgp_key}"
}

output "iam_id" {
  value = "${aws_iam_access_key.default.*.id}"
}

output "iam_key" {
  value = "${aws_iam_access_key.default.*.encrypted_secret}"
}
