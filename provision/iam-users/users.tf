module "users" {
  source = "./users"

  tf_state_bucket = "${var.tf_state_bucket}"
  group_name      = "${var.group_name}"
  users           = "${var.total_users}"
}
