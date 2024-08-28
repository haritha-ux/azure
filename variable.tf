variable "resource_group_name" {
  type        = string
  description = "name of the storage group"
  default     = "azure-terraform-group"

}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "storage_account_name" {
  type    = string
  default = "Terraformsa2008202412"
}