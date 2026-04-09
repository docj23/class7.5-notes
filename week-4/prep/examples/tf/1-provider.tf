# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project     = "seir-1"
  region      = "us-east1"
  zone = "us-east1-b"
  credentials = "../../../../032326-tf-key.json"
}