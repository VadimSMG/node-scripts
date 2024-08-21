terraform {
required_providers {
    contabo = {
      source = "contabo/contabo"
      version = ">= 0.1.26"
    } 
  }
}
#Налаштування авторизації на ресурсі Contabo.
provider "contabo" {
  #Використання облікових даних профілю на Contabo. Знаходяться у Contabo Control Panel.
  oauth2_client_id = var.client_id #ID акаунту. 
  oauth2_client_secret = var.client_secret #Пароль акаунту.
  oauth2_user = var.api_user #API пароль.
  oauth2_pass = var.api_password #API користувача. Це емейл, на якиз раеєстровано профіль.
  oauth2_token_url = var.access_token #Токен oauth2. Отримати за адресою https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token
}
#Налаштування параметрів імпортуємого серверу.
resource "contabo_instance" "test_instance" {
  name = "vmi1063448"
  #image_id = "afecbb85-e2fc-46f0-9684-b46b1faf00bb"
  dislay_name = ""
  product_id = "V36"
  region = "EU"
}
