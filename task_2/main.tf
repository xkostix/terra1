terraform {
  required_version = ">= 1.5"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "docker" {
  host = "ssh://mks-yandex"
}


resource "random_password" "mysql_root" {
  length  = 16
  special = false
}

resource "random_password" "mysql_wordpress" {
  length  = 16
  special = false
}

# image
resource "docker_image" "mysql" {
  name = "mysql:8"
}

# том для БД
resource "docker_volume" "mysql_data" {
  name = "mysql-data"
}


# Контейнер
resource "docker_container" "mysql" {
  name  = "mysql"
  image = docker_image.mysql.image_id

  restart = "unless-stopped"

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_wordpress.result}",
    "MYSQL_ROOT_HOST=%"
  ]

  ports {
    ip       = "127.0.0.1"
    internal = 3306
    external = 3306
  }

  mounts {
    target = "/var/lib/mysql"
    source = docker_volume.mysql_data.name
    type   = "volume"
  }
}
