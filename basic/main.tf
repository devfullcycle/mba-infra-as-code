terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }

    random = {
      source = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

resource "random_pet" "meu_pet" {
  length = 3
  prefix = "Sr."
  separator = " "
}

resource "local_file" "exemplo" {
  filename = "exemplo.txt"
  content = <<EOF
Conteúdo: ${var.file_content}

Meu pet: ${random_pet.meu_pet.id}

Valor booleano: ${var.var_bool}

Fruits: ${length(var.fruits)}

Name: ${var.person_map.name}
Age: ${var.person_map.age}

Name: ${var.person_tuple[0]}
Age: ${var.person_tuple[1]}

Name: ${var.person.name}
Age: ${var.person.age}
EOF
}