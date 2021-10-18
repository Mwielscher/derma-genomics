## Table of contents  
1. [About this Repository](#About-this-Repository)
2. [Set up your GCP project](#Instructions-to-use-the-Jupyterhub-on-the-VSC)
3. [create a service account](#create-a-service-account)
4. [provision and set up a cromwell server](provision-and-set-up-a-cromwell-server)  
5. [run GATK best practices workflows](run-GATK-best-practices-workflows)
6. [Provisioning MySQL server](Provisioning-MySQL-server)
7. [Creating NAT and configuring Private Google Access and Firewall](#Creating-NAT-and-configuring-Private-Google-Access-and-Firewall)
8. [Deploy cromwell sql server](Deploy-cromwell-sql-server)



## About this Repository  
This repository gives detailed instructions on how to use [Google Life Science API](https://cloud.google.com/life-sciences/docs/reference/rest) in connection with GATK best practices workflows from within the European Union. Workflows are written in [workflow description language](https://github.com/openwdl/wdl) and run by [cromwell workflow engine](https://cromwell.readthedocs.io/en/develop/) both developed and maintained at Broad Institute. The goal of this code repository is to get from [uBAM files](https://gatk.broadinstitute.org/hc/en-us/articles/360035532132-uBAM-Unmapped-BAM-Format) (i.e. raw files from WGS run) to [VCF files](https://samtools.github.io/hts-specs/VCFv4.2.pdf) in standardized and reproducible environment.  

__The architecture including all necessary components is given below:__  
<p align="center">
<img src="/png/architecture.png" alt="architecture" width="700"/>
<br/><br/>
  

## set up your GCP project  

* __Setup a google project__ with an active billing acount. You need to be __Owner__ or at least __????Editor???__ in the project to be able to set up and run the described workflow.
* __Enable the Life Science API__: In the search box at the top search for Life Sciences API, select the API then Click on the Enable button. 
* We will be using the following __APIs:__ (either with as user or via the service account we will be creating for this) Compute Engine API, Cloud Life Sciences API, Dataflow API, Cloud Logging API, Cloud Deployment Manager V2 API, Cloud Monitoring API, BigQuery API, Cloud SQL Admin API, Cloud Resource Manager API, Service Usage API, Service Networking API, BigQuery Storage API, Cloud Datastore API, Cloud Debugger API, Cloud OS Login API, Cloud SQL, Cloud Storage, Cloud Storage API, Cloud Trace API, Genomics API, Google Cloud APIs, Google Cloud Storage JSON API,Service Management API  
* Create a regional standard Cloud __Storage Bucket__, it should be placed in the same region as the worker nodes. You can also consider using Dual or multi regions if the workers will be in multiple regions.

## create a service account
1. Click on IAM & Admin→Service Accounts  
2. Click “Create Service Account”  
3. Enter Service account name e.g “wdl-runner”  
4. Add appropriate description  
5. Click “Create and Continue”  
6. Add the following roles  
>* 1. Cloud SQL Admin  
>* 2. Cloud Life Sciences Workflows Runner  
>* 3. Service Usage Consumer  
>* 4. Storage Object Admin  
7. Click Done  
8. Click on the service account then select “KEYS” tab  
9. Click Add Key → Create new key  
10. Click Create, download the key to a secure location and rename to credentials.json  



## provision and set up a Cromwell server  

I usually start with an e2-standard-4 instance and later adjust the size based on recommendation on the console. Smaller instances will still work as well.

>* 1. Create new VM cromwell-server
>* 2. Set the zone to \<zone\>
>* 3. Select appropriate size based on expected number of workflows, you can start with e2-standard-4
>* 4. Update Access scope to Allow full access to all Cloud APIs
>* 5. Expand Networking and add a network tag “cromwell-iap” (the why and how be described in [this section](#Creating-NAT-and-configuring-Private-Google-Access-and-Firewall))
>* 6. Expand the network interface and change External IP address to ‘None’
>* 7. Click Create

to run cromwell on this instance follow the installation requirements in this [script](/cromwell_server/setup_cromwell.sh) (to be replaced by docker file) 

Updating the [conf file](/cromwell_server/PAPIv2-EU.conf)

Edit the following values
* project-id 
* service account email
* storage-bucket 
* Location and endpoint-url if not using us-central1
* zones (set to europe-west4)
* database IP and password 
  
Upload the conf file and the credentials.json created earlier to the VM



## run GATK best practices workflows 

ssh to the cromwell server. Copy over the config file and the GATK wdl and json files. 

run the preprocessing pipeline:
~~~
 java -Dconfig.file=PAPIv2-EU.conf -jar cromwell-66.jar run  ~/gatk4-data-processing/processing-for-variant-discovery-gatk4.wdl \
-i ~/processing-for-variant-discovery-gatk4.hg38.wgs.inputs.json -o generic.google-papi.options.json
~~~  

run haplocaller:

~~~
java -Dconfig.file=PAPIv2-EU.conf -jar cromwell-66.jar run ~/gatk4-germline-snps-indels/haplotypecaller-gvcf-gatk4.wdl \
-i ~/haplotypecaller-gvcf-gatk4.hg38.wgs.inputs.json 
~~~

run mutect2 to call somatic variants:
~~~
java -Dconfig.file=PAPIv2-EU.conf -jar cromwell-69.jar run ~/gatk4-somatic-snvs-indels/mutect2.wdl \
-i ~/mutect2.inputs.json -o generic.google-papi.options.json
~~~

  
  
 
## Provisioning MySQL server  
There are many advantages to running Cromwell with MySQL, being able to run in server mode and submit multiple Jobs, sharing output and being able to view timing charts, resuming failed pipelines, etc.

The instance type and disk size depends on the number of parallel pipelines expected to run. In this tutorial I start with a n1-standard-1 instance type and 20GB SSD disk which I found to  be more than enough to run a few parallel pipelines.  
  
1. Browse to Cloud SQL and Create Instance  
2. Choose MySQL,  you may need to enable the API  
3. Change to Single Zone availability  
4. Update the Region/Zone to match cromwell server location  
5. Click on Show Configuration options  
6. Update Machine Type  
7. Update Storage and resize if needed  
8. Expand Connections and uncheck Public IP and select Private IP  
9. Select the Network where the Server will be running, usually default  
10. You may need to set-up Private service access connection if you have not done this before for this VPC, Click Enable API  and select ‘Use an automatically allocated IP range. Click Continue, then Create Connection as outlined below:  
<p align="center">
<img src="/png/sql_access.png" alt="sql_access1" width="600"/>
<br/>
<p align="center">
<img src="/png/sql_access2.png" alt="sql_access2" width="500"/>
<br/><br/>  
  
11. Click on create instance  
12. Once the database has been created, click on the instance, then Databases and create a new database “cromwell”  
13. Note the private ip address <db-ipaddress> as it will be used later in the config file  

  
## Creating NAT and configuring Private Google Access and Firewall

  
  
## Deploy cromwell sql server 


