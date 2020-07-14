terraform {
    backend "gcs" {
        bucket = "ot-core-share-terraform"
        prefix = "terraform2"
        #encrypt = true
    }
}
