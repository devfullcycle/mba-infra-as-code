variable "file_content" {
  default = "Conteúdo default"
  description = "Essa variável representa o valor a ser salvo no arquivo."
  type = string
}

variable "var_bool" {
  default = false
  type = bool
}