/** we write it once and reference it everywhere */
locals {
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = {
    App         = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  azs     = ["${var.aws_region}a", "${var.aws_region}b"]
  eks_azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}
