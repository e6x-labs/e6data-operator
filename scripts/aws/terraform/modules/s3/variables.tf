variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket"
}

variable "e6data_tags" {
  type = map(string)
  description = "e6data specific tags for isaolation and cost management"
}