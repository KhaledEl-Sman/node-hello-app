variable "aws_region" {
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "cluster_name" {
  default = "hello-node-cluster"
}

variable "node_instance_types" {
  default = ["t3.small"]
}

variable "profile" {
  default = "eks-terraform"
}

variable "principal_arn" {
  default = "arn:aws:iam::<acountId>:user/<userName>"
}
