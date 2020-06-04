terraform {
    backend "gcs" {
        bucket = "gke-from-scratch-terraform-state-ibro"
        prefix = "terraform2"
        #credentials = "account.json"
    }
}
