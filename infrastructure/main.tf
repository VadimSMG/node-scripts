terraform {
  required_providers {
    contabo = {
      source = "contabo/contabo"
      version = "~> 1.0"
    } 
  }
}
#Налаштування авторизації на ресурсі Contabo.
provider "contabo" {
  #Використання облікових даних профілю на Contabo. Знаходяться у Contabo Control Panel.
  oauth2_client_id = "" #ID акаунту. 
  oauth2_client_secret = "" #Пароль акаунту.
  oauth_user = "" #API пароль.
  oauth_pass = "" #API користувача. Це емейл, на якиз раеєстровано профіль.
  oauth2_token_url = "" #Токен oauth2. Отримати за адресою https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token
}
#Налаштування параметрів імпортуємого серверу.
resource "contabo_instance" "test_instance" {
  dislay_name = "194.163.134.151"
  product_id = ""
}
