variable "access_log" {
  default     = false
  description = "Whether to enable access logging"
}

variable "port" {
  default     = 80
  description = "The port to listen on (just one, because we use an ALB to terminate SSL)"
}

variable "image" {
  default     = "traefik:2.5.4"
  description = "The Docker image to run"

  validation {
    condition     = can(regex("^traefik:", var.image))
    error_message = "You must use a traefik image and include the version."
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
    error_message = "Must be one of DEBUG, INFO, WARN, ERROR, FATAL, PANIC."
  }
}

variable "insecure_skip_verify" {
  default     = false
  description = "If your endpoints use SSL with self-signed certs, you need to turn this on. Looking at you Ubiquiti!"
}

variable "node_selector" {
  default     = {}
  type        = map(string)
  description = "Node selector for the daemonset pods"
}
