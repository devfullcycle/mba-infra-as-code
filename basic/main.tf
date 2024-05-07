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
  content = <<EOF
Valor string: ${var.file_content} Valor booleano: ${var.var_bool}

Fruits: ${length(var.fruits)}

Name: ${var.person_map.name}
Age: ${var.person_map.age}

Name: ${var.person_tuple[0]}
Age: ${var.person_tuple[1]}

Name: ${var.person.name}
Age: ${var.person.age}
EOF
}