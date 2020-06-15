#set -x
#set -e


# Pendig when this is an actual script, you may have to copy and paste

projectname="otl-eng-core-share-ops"
rolename="terraform-perm"

# There is a role created at projects/otl-eng-core-share-ops/roles/terraformperm1, update the perms.yaml file accordingly so Terraform can have permissions

gcloud iam roles update terraformperm1 --project ${projectname} --file perms.yaml 

# if you see an etag error, paste this into the perms file
etag=$(gcloud iam roles describe terraformperm1 --project otl-eng-core-share-ops | grep etag)  ; echo $etag 

#create the service account
gcloud iam service-accounts create terraform --display-name "Terraform admin account"

#Bind the custom role we created for Terraform to the service account
gcloud iam service-accounts add-iam-policy-binding terraform@${projectname}.iam.gserviceaccount.com --member="serviceAccount:terraform@${projectname}.iam.gserviceaccount.com" --role=projects/${projectname}/roles/terraformperm1

#Bind the Service Account User role as well
gcloud iam service-accounts add-iam-policy-binding terraform@${projectname}.iam.gserviceaccount.com --member="serviceAccount:terraform@${projectname}.iam.gserviceaccount.com" --role=roles/iam.serviceAccountUser

#Create path to store the credentials
credpath="/Users/bagunbiade/.ssh/spaces-aws/"

mkdir -p ${credpath}

#Create key
gcloud iam service-accounts keys create ${credpath}/terraform.json --iam-account terraform@${projectname}.iam.gserviceaccount.com

#export variable or pass into Providers.credential in your Terraform file
export GOOGLE_APPLICATION_CREDENTIALS="/Users/bagunbiade/.ssh/spaces-aws/terraform.json"  
