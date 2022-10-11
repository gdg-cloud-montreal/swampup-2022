terraform {
  backend "gcs" {
    bucket = "swampup-tfstate"
    prefix = "state"
  }
}
