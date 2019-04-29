module "users" {
  source = "./users"

  tf_state_bucket = "${var.tf_state_bucket}"
  group_name      = "${var.group_name}"
  users           = "${var.total_users}"
  pgp_key         = "${var.pgp_key}"
}

output "iam_ids" {
  value = "${module.users.iam_id}"
}

output "iam_keys" {
  value = "${module.users.iam_key}"
}
