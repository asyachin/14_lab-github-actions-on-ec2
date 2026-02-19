variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "ec2-server"
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If not provided, will use latest Ubuntu 24.04 LTS"
  type        = string
  default     = ""
}
