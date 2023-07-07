variable "project" {
  description = "Name of the project"
  default     = "okera"
}

variable "env" {
  description = "Name of the environment"
  default     = "dev"
}

variable "region" {
  description = "Name of the region"
  default     = "us-west-2"
}

variable "ec2_ami" {
  description = "EC2 AMI to use on us-west-2"
  default     = "ami-017fecd1353bcc96e"
}

variable "name" {
  description = "EC2 name"
  default     = "github-runner"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "iam_instance_profile" {
  description = "EC2 iam_instance_profile role"
  default     = "Jenkins_role"
}

variable "volume_type" {
  description = "EC2 volume type"
  default     = "gp2"
}

variable "volume_size" {
  description = "EC2 volume size"
  default     = "20"
}

variable "keyfile_name"{
  description = "pem key name"
  default = "dev-infra-1"
}

variable "user_data_script"{
  description = "user-data initialization script"
  default = "scripts/configRunner.sh"
}


variable "min_size" {
  description = "EC2 min amount of nodes"
  default     = "5"
}


variable "max_size" {
  description = "EC2 min amount of nodes"
  default     = "20"
}


variable "desired_capacity" {
  description = "EC2 desired amount of nodes"
  default     = "2"
}
