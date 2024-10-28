###################################
#
# Programador: Danae Barba Montemayor
#
# Fecha Creacion: 26-Oct-2024
# Fecha Modificacion: 26-Oct-2024
#
#####################################

#LLave de acceso
variable "AWS_Key" {
    description = "Llave de acceso a AWS"
    type = string
}

#Clave secreta
variable "AWS_Secret" {
  description = "Clave secreta"
  type = string
}

#Region de trabajo
variable "Region_AWS" {
  description = "Region donde desarrollaremos el proyecto"
  default = "us-east-1"
}