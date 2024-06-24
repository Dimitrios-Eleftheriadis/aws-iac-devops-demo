variable "account" {
  type = map(map(string))
}

variable "region" {
    type = map(string)
}

variable "region_label" {
  type = map(string)
}


variable "distribution_lists" {
  type = map(map(list(string)))
}

variable "project_name" {
  type = string
}