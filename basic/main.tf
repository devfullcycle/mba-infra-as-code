terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

resource "local_file" "exemplo" {
  filename = "exemplo.txt"
  content = "Valor string: ${var.file_content} Valor booleano: ${var.var_bool}"
}