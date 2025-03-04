locals {
  a="remove_bakery_ami"
  b=replace(local.a,"_","-")
}
output "name" {
  value = local.b
}