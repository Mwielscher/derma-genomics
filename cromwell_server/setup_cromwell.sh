sudo apt-get install unzip
sudo apt-get install wget
sudo apt-get install zip
sudo apt install git
sudo apt-get install screen
curl -s "https://get.sdkman.io" | bash
sdk install java
wget https://github.com/broadinstitute/cromwell/releases/download/66/cromwell-66.jar
##  ------------------------------------------------------------------------
## check/set up instance using your service account
#wdl-runner is the name of my service account
#genomics-3**1 is the project ID at GCP
gcloud auth activate-service-account wdl-runner@genomics-3**1.iam.gserviceaccount.com --key-file=genomics-3**1-5**f.json --project=genomics-3**1
gcloud auth login
gcloud compute instances describe wdl-runner

###  now try hello world script
java -Dconfig.file=PAPIv2-EU.conf -jar cromwell-66.jar run hello.wdl -i hello.inputs
