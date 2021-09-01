provider "aws" {
  default_tags {
    tags = {
      usage   = "test"
      project = "study"
    }
  }
}

