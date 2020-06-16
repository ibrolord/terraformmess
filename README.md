## Installing Google SDK (macOS)
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
3. Initialize the Google Cloud SDK
```
gcloud init
# For project, choose otl-eng-core-share-ops 
```

## Setting up Terraform (macOS)
1. Install terraform
```
brew install terraform
```
2. 

![Network Diagram](/network_diagram.pdf)
