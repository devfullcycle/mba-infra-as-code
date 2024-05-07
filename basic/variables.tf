variable "file_content" {
  default = "Conteúdo default"
  description = "Essa variável representa o valor a ser salvo no arquivo."
  type = string
}

variable "var_bool" {
  default = false
  type = bool
}

variable "fruits" {
  type    = list(string)
  default = ["apple", "banana", "apple"]
}

variable "person_map" {
  type    = map(string)
  default = {
    name = "Igor"
    age  = 28
  }
}

variable "person_tuple" {
  type    = tuple([ string, number ])
  default = ["Igor", 28]
}

variable "person" {
  type    = object({
    name  = string
    age   = number
  })
  default = {
    name = "Igor"
    age  = 28
  }
}