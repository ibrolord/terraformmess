terraform {
    backend "gcs" {
        bucket = "ot-core-share-terraform"
        prefix = "backend-services-v1"
    }
}
