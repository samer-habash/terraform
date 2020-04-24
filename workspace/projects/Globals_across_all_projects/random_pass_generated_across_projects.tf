/*
I will generate an rds_app_project password that has ascii only as proposed in the terraform error below:
Error creating DB Instance: InvalidParameterValue: The parameter MasterUserPassword is not a valid password.
Only printable ASCII characters besides '/', '@', '"', ' ' may be used.

- This is bug from terrafor ,(They understand it opposite way)
The pass cannot contain special characters mentioned by aws :
Master passwordInfo
•••
Constraints: At least 8 printable ASCII characters. Can't contain any of the following: / (slash), "(double quote) and @ (at sign).
*/

resource "random_password" "rds_random_pass" {
  length = 16
  special = true
  override_special = "$%*"
}
output "rds_random_pass_generation" {
  value = random_password.rds_random_pass.result
}

resource "random_password" "projects_random_pass" {
  length = 16
  special = true
  override_special = "$!#%@"
  // minimum special charachters
  min_special = 3
}
output "projects_random_pass_generation" {
  value = random_password.projects_random_pass.result
}