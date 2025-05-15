resource "google_service_account" "provisioner" {
  account_id   = local.provisioner_service_account
  display_name = "${local.name}-provisioner-sa"
  project      = local.project_id
}

resource "google_project_iam_member" "instance_admin" {
  project = local.project_id
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:${google_service_account.provisioner.email}"
}