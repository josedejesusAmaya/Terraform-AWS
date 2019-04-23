resource "aws_iam_user" "default" {
  count = "${var.users}"

  name = "${var.name}-${count.index}"
}

resource "aws_iam_user_policy" "default" {
  count = "${var.users}"

  name   = "ec2-and-route53"
  user   = "${element(aws_iam_user.default.*.name, count.index)}"
  policy = "${element(data.aws_iam_policy_document.default.*.json, count.index)}"
}

data "aws_iam_policy_document" "default" {
  count = "${var.users}"

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}",
      "arn:aws:s3:::${var.tf_state_bucket}/${element(aws_iam_user.default.*.name, count.index)}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:HeadBucket",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_user_group_membership" "default" {
  count = "${var.users}"

  user = "${element(aws_iam_user.default.*.name, count.index)}"

  groups = [
    "${var.group_name}",
  ]
}
