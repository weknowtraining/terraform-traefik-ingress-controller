variable "access_log" {
  default     = false
  description = "Whether to enable access logging"
}

variable "port" {
  default     = 80
  description = "The port to listen on (just one, because we use an ALB to terminate SSL)"
}

variable "image" {
  default     = "traefik:1.7.28"
  description = "The Docker image to run"

  validation {
    condition     = can(regex("^traefik:", var.image))
    error_message = "You must use a traefik image and include the version"
  }
}

variable "namespace" {
  default     = "kube-system"
  description = "The k8s namespace to create resources in"
}

variable "log_level" {
  default     = "INFO"
  description = "The log level to use"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR", "FATAL", "PANIC"], var.log_level)
    error_message = "Must be one of DEBUG, INFO, WARN, ERROR, FATAL, PANIC"
  }
}
