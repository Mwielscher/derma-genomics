## Table of contents  
1. [About this Repository](#About-this-Repository)
2. [Set up your GCP project](#Instructions-to-use-the-Jupyterhub-on-the-VSC)


4. [Creating NAT and configuring Private Google Access and Firewall](#Creating-NAT-and-configuring-Private-Google-Access-and-Firewall)


## About this Repository  
This repository gives detailed instructions on how to use [Google Life Science API](https://cloud.google.com/life-sciences/docs/reference/rest) in connection with GATK best practices workflows from within the European Union. Workflows are written in [workflow description language](https://github.com/openwdl/wdl) and run by [cromwell workflow engine](https://cromwell.readthedocs.io/en/develop/) both developed and maintained at Broad Institute. The goal of this code repository is to get from [uBAM files](https://gatk.broadinstitute.org/hc/en-us/articles/360035532132-uBAM-Unmapped-BAM-Format) (i.e. raw files from WGS run) to [VCF files](https://samtools.github.io/hts-specs/VCFv4.2.pdf) in standardized and reproducible environment. 
<br/><br/>

## set up your GCP project

* __Setup a google project__ with an active billing acount. You need to be __Owner__ or at least __????Editor???__ in the project to be able to set up and run the described workflow.
* __Enable the Life Science API__: In the search box at the top search for Life Sciences API, select the API then Click on the Enable button. 
* We will be using the following __APIs:__ (either with as user or via the service account we will be creating for this) Compute Engine API, Cloud Life Sciences API, Dataflow API, Cloud Logging API, Cloud Deployment Manager V2 API, Cloud Monitoring API, BigQuery API, Cloud SQL Admin API, Cloud Resource Manager API, Service Usage API, Service Networking API, BigQuery Storage API, Cloud Datastore API, Cloud Debugger API, Cloud OS Login API, Cloud SQL, Cloud Storage, Cloud Storage API, Cloud Trace API, Genomics API, Google Cloud APIs, Google Cloud Storage JSON API,Service Management API  
* Create a regional standard Cloud __Storage Bucket__, it should be placed in the same region as the worker nodes. You can also consider using Dual or multi regions if the workers will be in multiple regions.

## provision and set up a Cromwell server

I usually start with an e2-standard-4 instance and later adjust the size based on recommendation on the console. Smaller instances will still work as well.

>* 1. Create new VM cromwell-server
>* 2. Set the zone to \<zone\>
>* 3. Select appropriate size based on expected number of workflows, you can start with e2-standard-4
>* 4. Update Access scope to Allow full access to all Cloud APIs
>* 5. Expand Networking and add a network tag “cromwell-iap” (the why and how be described in [this section](#Creating-NAT-and-configuring-Private-Google-Access-and-Firewall))
>* 6. Expand the network interface and change External IP address to ‘None’
>* 7. Click Create

to run cromwell on this instance follow the installation requirements in this [script](/cromwell_server/setp_cromwell.sh) (to be replaced by docker file) 


## Creating NAT and configuring Private Google Access and Firewall

