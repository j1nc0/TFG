#GENERAL

variable "region" {
  type        = string
  description = "region of the deployment"

}

variable "profile" {
  type        = string
  description = "aws account profile"
}

variable "project_name" {
  type        = string
  description = "project name"
}


#DB

variable "db_type" {
  type        = string
  description = "type of database. Aurora or rds"
}

variable "db_instance_type" {
  type        = string
  description = "instance type of the database"
  default     = "db.t3.micro"
}

variable "db_storage" {
  type        = number
  description = "GB of db storage, autoscaling max storage will be 10x if enabled"
  default     = null
}

variable "db_backups" {
  type        = bool
  description = "enable backups"
  default     = true
}

variable "db_encrypted" {
  type        = bool
  description = "defines if storage is encrypted"
}


#Elasticache

variable "elasticache_engine" {
  type        = string
  description = "elasticache engine type"
}

variable "elasticache_instance_type" {
  type        = string
  description = "instance type of the elasticache"
  default     = "cache.t3.micro"
}

variable "cluster_mode" {
  type        = bool
  description = "enable cluster mode"
  default     = false
}

variable "number_read_replicas" {
  type        = number
  description = "number of read replicas, if cluster mode enabled, number of read replicas per shard (or node group)"
}

variable "elasticache_encrypted" {
  type        = bool
  description = "enable elasticache encryption"
  default     = null
}


#AUTOSCALING

variable "spot_price" {
  type        = string
  description = "spot price"
  default     = null
}

variable "is_spot" {
  type        = bool
  description = "is the instance spot?"
  default     = false
}

variable "autoscaling_max_size" {
  type        = number
  description = "max autoscaling instances allowed"
}

variable "autoscaling_min_size" {
  type        = number
  description = "min autoscaling instances allowed and starting number"
}

variable "policy_scale_up" {
  type        = number
  description = "Create a new instance when general CPU usage is above"
}

variable "policy_scale_down" {
  type        = number
  description = "Delete an existing instance when general CPU usage is below"
}

variable "instance_type" {
  type        = string
  description = "type of the instances to be deployed"
}

#Cloudfront

variable "georestrictions_cloudfornt" {
  type        = list(any)
  description = "list of regions that are georestricted and content can't be delivered there"
  default     = null
}

#DNS

variable "domain" {
  type        = string
  description = "domain name of the web service"
}

#BASTION HOSTS

variable "personal_ip" {
  type        = string
  description = "IP to connect to the bastion host"
}

#KEYS/CREDENTIALS

variable "ssh_public_key" {
  type        = string
  description = "public key file located in ~/.ssh in order to connect to the bastion hosts"
  sensitive   = true
}

variable "secretmanager_secret_id" {
  type        = string
  description = "the secret id that contains the username and password of the database"
}

#BACKEND

variable "workspace" {
  type        = string
  description = "workspace of the terraform state"
}