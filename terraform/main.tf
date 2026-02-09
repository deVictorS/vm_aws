#terraform apply -var="status_da_vm=running" para ligar
#terraform apply -var="status_da_vm=stopped" para desligar


variable "status_da_vm" {
  description = "Estado da instância: running ou stopped"
  type = string
  default = "running" 
}

resource "aws_ec2_instance_state" "estado_maquina_web" {
  instance_id = aws_instance.maquina_web.id
  state = var.status_da_vm
  
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "chave_vm" {
  key_name = "aws_estudo"
  public_key = file("../keys/aws_estudo.pub")
}

resource "aws_security_group" "acesso_ssh" {
  name = "acesso_ssh"
  description = "Permitir SSH"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["200.131.56.36/32"] #meu ip real
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "maquina_web" {
    ami = "ami-0b6c6ebed2801a5cb" #ubuntu lts (verificar id da regiao)
    instance_type = "t3.micro" #grátis
    key_name = aws_key_pair.chave_vm.key_name

    vpc_security_group_ids = [aws_security_group.acesso_ssh.id]

    tags = {
        Name = "VM_ESTUDO"
    }
}

output "ip_publico" {
    value = aws_instance.maquina_web.public_ip
}