IMPORTANT ❗ ❗ ❗ Please remember to destroy all the resources after each work session. You can recreate infrastructure by creating new PR and merging it to master.
  
![img.png](doc/figures/destroy.png)


1. Authors:

   Gr.2
   Mateusz Szczęsny, Mateusz Borkowski, Maksim Makaranka

   https://github.com/mati9456/tbd-2023z-phase1
   
2. Fork https://github.com/bdg-tbd/tbd-2023z-phase1 and follow all steps in README.md.

3. Select your project and set budget alerts on 5%, 25%, 50%, 80% of 50$ (in cloud console -> billing -> budget & alerts -> create buget; unclick discounts and promotions&others while creating budget).

  ![img.png](doc/figures/discounts.png)

4. From avaialble Github Actions select and run destroy on main branch.

5. Create new git branch and add two resources in ```/modules/data-pipeline/main.tf```:
    1. resource "google_storage_bucket" "tbd-data-bucket" -> the bucket to store data. Set the following properties:
        * project  // look for variable in variables.tf
        * name  // look for variable in variables.tf
        * location // look for variable in variables.tf
        * uniform_bucket_level_access = false #tfsec:ignore:google-storage-enable-ubla
        * force_destroy               = true
        * public_access_prevention    = "enforced"
        * if checkcov returns error, add other properties if needed
       
    2. resource "google_storage_bucket_iam_member" "tbd-data-bucket-iam-editor" -> assign role storage.objectUser to data service account. Set the following properties:
        * bucket // refere to bucket name from tbd-data-bucket
        * role   // follow the instruction above
        * member = "serviceAccount:${var.data_service_account}"

    ***insert the link to the modified file and terraform snippet here***
   https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/data-pipeline/main.tf
   ```
    resource "google_storage_bucket" "tbd-data-bucket" {
    project                     = var.project_name
    name                        = var.data_bucket_name
    location                    = var.region
    uniform_bucket_level_access = false #tfsec:ignore:google-storage-enable-ubla
    force_destroy               = true
    #checkov:skip=CKV_GCP_62: "Bucket should log access"
    #checkov:skip=CKV_GCP_29: "Ensure that Cloud Storage buckets have uniform bucket-level access enabled"
    #checkov:skip=CKV_GCP_78: "Ensure Cloud storage has versioning enabled"
    public_access_prevention    = "enforced"
    }
  
    resource "google_storage_bucket_iam_member" "tbd-data-bucket-iam-editor" {
    bucket = google_storage_bucket.tbd-data-bucket.name
    role   = "roles/storage.objectUser"
    member = "serviceAccount:${var.data_service_account}"
    }
   ```
  
   wynik komendy ```terraform plan -var-file ./env/project.tfvars -compact-warnings``` :
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/43956a1c-5a07-464f-9832-e46af0bb1c05)

    Create PR from this branch to **YOUR** master and merge it to make new release. 
    
    ***place the screenshot from GA after succesfull application of release with this changes***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/42de3c55-270e-4a55-8732-498bc40880af)


6. Analyze terraform code. Play with terraform plan, terraform graph to investigate different modules.
   

```terraform plan -target=module.data-pipelines.google_storage_bucket.tbd-data-bucket -var-file ./env/project.tfvars -compact-warnings -out plan.txt```
```terraform graph -plan=plan.txt | dot -Tsvg > graph.svg```

    ***describe one selected module and put the output of terraform graph for this module here***

![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/ddcdec60-3562-40bb-91af-da012eac7ae6)

The ***Dataproc*** modul was selected for the description. It provides a fully managed and highly scalable service for running Apache Hadoop, Spark, Flink and others. It allows data users integration with different GCP services, such as ***Vertex AI***, ***BigQuery*** and ***Dataplex***. Key features of the ***Dataproc*** include:
- Serverless Spark that autoscale without any manual infrastructure provisioning or tuning
- Resizable clusters with various virtual machine types, disk sizes, number of nodes, and networking options
- Autoscaling clusters with a mechanism for automating cluster resource management
- Automated security management across all clusters

The main.tf file contains a description of the resources that terraform creates for this module:
- Resourse `google_project_service` allows management of a single API service for a GCP project
- Resource `google_dataproc_cluster` manages a cloud ***Dataproc*** cluster resource within GCP. It requires project specification and cluster configuration, including the setup of master and worker machines
   
7. Reach YARN UI
   
   ***place the port and the screenshot of YARN UI here***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/fd088579-a464-4b26-b1b1-7cf59d914097)

   
8. Draw an architecture diagram (e.g. in draw.io) that includes:
    1. VPC topology with service assignment to subnets
    2. Description of the components of service accounts
    3. List of buckets for disposal
    4. Description of network communication (ports, why it is necessary to specify the host for the driver) of Apache Spark running from Vertex AI Workbech
  
    ***place your diagram here***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/d3e44239-2e89-4e1b-af9a-9af1615a6966)

10. Add costs by entering the expected consumption into Infracost

   ***place the expected consumption you entered here***
   https://github.com/mati9456/tbd-2023z-phase1/blob/infracost/infracost-usage.yml

   ***place the screenshot from infracost output here***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/38502f80-cf85-4426-b045-283fed5ed4b2)


11. Some resources are not supported by infracost yet. Estimate manually total costs of infrastructure based on pricing costs for region used in the project. Include costs of cloud composer, dataproc and AI vertex workbanch and them to infracost estimation.

    Rersources not caculated by infracost (shown by running infracost breakdown with --show-skipped flag):
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/6f0be827-53fb-43a6-b54d-a8dfd3b79fb7)

    ***place your estimation and references here***

      ***Dataproc*** on Compute Engine pricing is based on the size of ***Dataproc*** clusters and the duration of time that they run. The size of a cluster is based on the aggregate number of virtual CPUs across the entire cluster, including the master and worker nodes. The duration of a cluster is the length of time between cluster creation and cluster stopping or deletion.
      
      The Dataproc pricing formula is: `$0.010 * number of vCPUs * hourly duration`.
      
      So assuming we use cluster with 10 virtual CPUs for both master and worker nodes which run 6 hours a day, the daily cost will be:
      
      `daily_cost = $0.010 * 10 * 6 = $0.6`
       
      ***Cloud Composer*** uses more complicated pricing model, which differs for the different Composer version. In our project we use Composer 2.4.8, so Composer 2 pricing model should be used for the cost estimations. It depends on *Cloud Composer Compute SKUs* which represent Compute Engine capacity (used number of vCPUs, memory and storage), *Composer Database Storage* size, *Environment* and *Higly Resilent Environment* sizes and location. The pricing for the specific items is presented below.
      
      ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/11f11188-b8ea-4c19-adbf-1b883cf68ce1)
       
      ***Vertex AI*** is Google Cloud's machine learning platform, offering services for building, deploying, and managing machine learning models. Pricing for ***Vertex AI*** typically involves various factors, including costs of training, online prediction, batch prediction, model deployment, storage, data transfer, image and text generation, and others. The costs of training, deployment and prediction for e.g. ML model working with images are presented below:
      
      ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/67d3cd4a-c396-4e3a-a4f5-1cdfae56b003)

    ***what are the options for cost optimization?***
    Some of the most common ways to optimize cloud costs are:
    - Autoscaling - automatically adjust the number of machines to the current worload. 
    - Comitted Use Discounts - if we know we will be using a resource for a long time, cloud providers offer discounts for commiting to a longer contract 
    - Preemptible VMS - using cheaper preemtible VMs. The down side is that our systems need to be able to handle interrupts.
    - Rightsizing - choosing machines that provide resources closest to our needs. This allows us to not overpay for resources that we will not be using.  
    
12. Create a BigQuery dataset and an external table
    
    ***place the code and output here***
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/5c611f01-aa0f-4f65-8a1a-ec08a40970a8)

    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/f6d85216-5fda-42be-b5d8-7d1cca70736f)

    ***why does ORC not require a table schema?***
    As described in google cloud documentation on creating a table definition file:

    Avro, Parquet, and ORC are self-describing formats. Data files in these formats contain their own schema information. If you use one of these formats as an external data source, then BigQuery automatically retrieves the schema using the source data. When creating a table definition, you don't need to use schema auto-detection, and you don't need to provide an inline schema definition or schema file.

    source: [GCP documentation](https://cloud.google.com/bigquery/docs/external-table-definition)
  
13. Start an interactive session from Vertex AI workbench (steps 7-9 in README):

    ***place the screenshot of notebook here***
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/891f1345-8492-41b5-ac1f-d1ccdb417cc1)

   
14. Find and correct the error in spark-job.py

    ***describe the cause and how to find the error***
    We found the error in job details of Dataproc:
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/bae79d91-c519-4b10-b830-41570aa07432)

    following the error we found this in the spark-job.py file:
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/b2403f7f-bf5e-4fce-be5e-893adb2bdf7a)

    after correcting this and running the job manually, the job suceeded:
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/0a6adaa2-e2ca-4fd4-b036-61f8fc74b3dc)


15. Additional tasks using Terraform:

    1. Add support for arbitrary machine types and worker nodes for a Dataproc cluster and JupyterLab instance

    ***place the link to the modified file and inserted terraform code***
    modified files:
    - https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/dataproc/main.tf
    - https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/dataproc/variables.tf
    -https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/vertex-ai-workbench/main.tf
    -https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/vertex-ai-workbench/variables.tf

    
    inserted code:
    /dataproc/main.tf
    ```
    master_config {
      num_instances = var.dataproc_num_masters
      machine_type  = var.dataproc_master_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 100
      }
    }

    worker_config {
      num_instances = var.dataproc_num_workers
      machine_type  = var.dataproc_worker_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 100
      }
    }
    ```
    /dataproc/variables.tf
    ```
    variable "dataproc_num_workers" {
        type = number
        default = 2
        description = "number of dataproc workers"
    }

    variable "dataproc_num_masters" {
        type = number
        default = 1
        description = "number of dataproc workers"
    }

    variable "dataproc_master_machine_type" {
        type        = string
        default     = "e2-standard-2"
        description = "Machine type to use for master nodes"
    }

    variable "dataproc_worker_machine_type" {
        type        = string
        default     = "e2-medium"
        description = "Machine type to use for worker nodes"
    }
    ```
    /vertex-ai-workbench/main.tf
    ```
    resource "google_notebooks_instance" "tbd_notebook" {
        [...]
        machine_type = var.vertex_machine_type
        [...]
    }
    ```
    /vertex-ai-workbench/variables.tf
    ```
    variable "vertex_machine_type" {
        type = string
        default = "e2-medium"
        description = "Type of machine"
    }
    ```
    
    3. Add support for preemptible/spot instances in a Dataproc cluster

    ***place the link to the modified file and inserted terraform code***
    modified files:
    -https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/dataproc/main.tf
    -https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/dataproc/variables.tf

    /dataproc/main.tf:
    ```
    preemptible_worker_config {
        num_instances = var.num_preemptible_workers
    }
    ```
    /dataproc/variables.tf
    ```
    variable "num_preemptible_workers" {
        type = number
        default =  0
        description = "number of preemptible dataproc workers"
    }

    ```

    3. Perform additional hardening of Jupyterlab environment, i.e. disable sudo access and enable secure boot
    
    ***place the link to the modified file and inserted terraform code***
    modified file:
    - https://github.com/mati9456/tbd-2023z-phase1/blob/master/modules/vertex-ai-workbench/main.tf
    
    ```
    resource "google_notebooks_instance" "tbd_notebook" {
        [...]
        metadata = {
            vmDnsSetting : "GlobalDefault"
            notebook-disable-root = true
        }
        [...]
        shielded_instance_config {
            enable_secure_boot = false
        }
    }
    ```


    4. (Optional) Get access to Apache Spark WebUI

    ***place the link to the modified file and inserted terraform code***
