locals {
  project_tags = {
    contact      = "devops@uaice1.com"
    application  = "jupiter"
    project      = "uaice1"
    environment  = "${terraform.workspace}" # refers to your current workspace (dev, prod, etc)
    creationTime = timestamp()
  }
}