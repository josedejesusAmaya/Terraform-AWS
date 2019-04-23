resource "aws_iam_group" "default" {
  name = "${var.group_name}"
}

resource "aws_iam_group_policy_attachment" "ec2-full" {
  group      = "${aws_iam_group.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "route53" {
  group      = "${aws_iam_group.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "read-only" {
  group      = "${aws_iam_group.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy" "region-inline" {
  name  = "region"
  group = "${aws_iam_group.default.name}"

  policy = "${data.aws_iam_policy_document.region.json}"
}

data "aws_iam_policy_document" "region" {
  statement {
    not_actions = [
      "iam:*",
      "sts:*",
      "route53:*",
    ]

    effect    = "Deny"
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = [
        "${var.aws_region}",
      ]
    }
  }
}
