## Setting up Google SDK (macOS)
1. Make sure you have python version between 3.5 to 3.7, and 2.7.9 or higher
```
python -V
```
2. Download the installer
```
cd ~/Downloads
# Download the zipped installer
curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-296.0.1-darwin-x86_64.tar.gz -o ~/Downloads/google-cloud-sdk.tar.gz
# Extract the installer
tar -xzf ~/Downloads/google-cloud-sdk.tar.gz
# Run installer
~/Downloads/google-cloud-sdk/install.sh 
# Source the installed commands, or start a new terminal
source ~/.bash_profile 
```
3. Set up the Google Cloud SDK
```
# Init gcloud with project otl-eng-core-share-ops 
gcloud init
# Download terraform credentials
gcloud iam service-accounts keys create ${HOME}/terraform.json --iam-account terraform@otl-eng-core-share-ops.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/terraform.json"  
```

## Setting up Terraform (macOS)
1. Install terraform
```
brew install terraform
```

## Network Diagram ![EDIT](https://app.lucidchart.com/invitations/accept/dc617425-e474-4519-8f98-90a801354acf)
![Network Diagram](/network_diagram.png)
