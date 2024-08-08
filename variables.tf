variable "platform" {
  description = "Cloud platform (aws, azure, gcp)"
  type        = string
}

variable "instance_count" {
  description = "Number of PostgreSQL nodes"
  type        = number
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
}

variable "enable_pgbackrest" {
  description = "Enable pgBackRest"
  type        = bool
}
