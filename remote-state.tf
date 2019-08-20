terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "canelkatmis"
    workspaces {
      name = "canstack-tf-ws"
    }
  }
}
