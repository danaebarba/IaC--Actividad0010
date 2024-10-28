###################################
#
# Programador: Danae Barba Montemayor
#
# Fecha Creacion: 26-Oct-2024
# Fecha Modificacion: 26-Oct-2024
#
#####################################

provider "aws" {
  access_key = var.AWS_Key
  secret_key = var.AWS_Secret
  region = var.Region_AWS
}

# Creamos la VPC
resource "aws_vpc" "VPC10" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    name = "VPC-Actividad010a"
  }
}

# Creamos subred 1
resource "aws_subnet" "SubRedPub01" {
  vpc_id = aws_vpc.VPC10.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    name = "SubRedPublica_01"
  }
}

# Creamos subred 2
resource "aws_subnet" "SubRedPub02" {
  vpc_id = aws_vpc.VPC10.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    name = "SubRedPublica_02"
  }
}

# Creamos subred privada 1
resource "aws_subnet" "SubRedPriv01" {
  vpc_id = aws_vpc.VPC10.id
  cidr_block = "10.0.128.0/20"
  availability_zone = "us-east-1a"
  tags = {
    name = "SubRedPrivada_01"
  }
}

# Creamos subred privada 2
resource "aws_subnet" "SubRedPriv02" {
  vpc_id = aws_vpc.VPC10.id
  cidr_block = "10.0.144.0/20"
  availability_zone = "us-east-1b"
  tags = {
    name = "SubRedPrivada_02"
  }
}

#Crear internet GateWay
resource "aws_internet_gateway" "InternetGateWay" {
  vpc_id = aws_vpc.VPC10.id
  tags = {
    name = "InternetGatewayPrincipal"
  }
}

#Tabla de ruteo
resource "aws_route_table" "TablaRuteo" {
  vpc_id = aws_vpc.VPC10.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateWay.id
  }
  tags = {
    name = "Tabla de Ruteo predeterminada"
  }
}

#Asociacion entre tabla de ruteo y SubRedPublicaA
resource "aws_route_table_association" "AsociacionTRSRPubA" {
  subnet_id = aws_subnet.SubRedPub01.id
  route_table_id = aws_route_table.TablaRuteo.id
}

#Asociacion entre tabla de ruteo y SubRedPublicaB
resource "aws_route_table_association" "AsociacionTRSRPubB" {
  subnet_id = aws_subnet.SubRedPub02.id
  route_table_id = aws_route_table.TablaRuteo.id
}

#Asociacion entre tabla de ruteo y SubRedPrivadaA
resource "aws_route_table_association" "AsociacionTRSRPrivA" {
  subnet_id = aws_subnet.SubRedPriv01.id
  route_table_id = aws_route_table.TablaRuteo.id
}

#Asociacion entre tabla de ruteo y SubRedPrivadaB
resource "aws_route_table_association" "AsociacionTRSRPrivB" {
  subnet_id = aws_subnet.SubRedPriv02.id
  route_table_id = aws_route_table.TablaRuteo.id
}

# Grupos de seguridad
resource "aws_security_group" "SG-VPC010" {
  vpc_id = aws_vpc.VPC10.id
  #SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #RDP
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Permitir_SSH_HTTP_RDP"
  }
}

#Par de llaves
resource "aws_key_pair" "AWSLLaves" {
  key_name = "AWSLLaves"
  public_key = file("/Users/danaebarba/.ssh/id_rsa.pub")
}

#Instancia EC2 de Ubuntu
resource "aws_instance" "InstanciaUbuntu" {
  # Ubuntu 20.04 AMI
  ami = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.SubRedPub01.id
  vpc_security_group_ids = [aws_security_group.SG-VPC010.id]
  key_name = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "Instancia Ubuntu"
  }
}

#Instancia EC2 de Windows Server
resource "aws_instance" "InstanciaWindows" {
  # Windows Server AMI
  ami = "ami-0324a83b82023f0b3"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.SubRedPub02.id
  vpc_security_group_ids = [aws_security_group.SG-VPC010.id]
  key_name = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "Instancia Windows"
  }
}

#Output para la ip publica de Ubuntu
output "IPPublicaUbuntu" {
  value = aws_instance.InstanciaUbuntu.public_ip
  description = "La direccion IP publica de la instancia de Ubuntu"
}

#Output para el ID de la instancia de Ubuntu
output "IDUbuntu" {
  value = aws_instance.InstanciaUbuntu.id
  description = "El ID de la instancia de Ubuntu"
}

#Output para la ip publica de Ubuntu
output "IPPrivadaUbuntu" {
  value = aws_instance.InstanciaUbuntu.private_ip
  description = "La direccion IP privada de la instancia de Ubuntu"
}
#Output para la ip publica de Windows
output "IPPublicaWindows" {
  value = aws_instance.InstanciaWindows.public_ip
  description = "La direccion IP publica de la instancia de Windows"
}

#Output para el ID de la instancia de WIndows
output "IDWindows" {
  value = aws_instance.InstanciaWindows.id
  description = "El ID de la instancia de Window"
}
#Output para la ip publica de Windows
output "IPPrivadaWindows" {
  value = aws_instance.InstanciaWindows.private_ip
  description = "La direccion IP privada de la instancia de Windows"
}