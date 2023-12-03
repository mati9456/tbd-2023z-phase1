IMPORTANT ❗ ❗ ❗ Please remember to destroy all the resources after each work session. You can recreate infrastructure by creating new PR and merging it to master.
  
![img.png](doc/figures/destroy.png)


1. Authors:

   Gr.2
   Mateusz Szczęsny, Mateusz Borkowski, Maksim Makaranka

   https://github.com/mati9456/tbd-2023z-phase1
   
3. Fork https://github.com/bdg-tbd/tbd-2023z-phase1 and follow all steps in README.md.

4. Select your project and set budget alerts on 5%, 25%, 50%, 80% of 50$ (in cloud console -> billing -> budget & alerts -> create buget; unclick discounts and promotions&others while creating budget).

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


7. Analyze terraform code. Play with terraform plan, terraform graph to investigate different modules.
   

```terraform plan -target=module.data-pipelines.google_storage_bucket.tbd-data-bucket -var-file ./env/project.tfvars -compact-warnings -out plan.txt```
```terraform graph -plan=plan.txt | dot -Tsvg > graph.svg```
![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/ddcdec60-3562-40bb-91af-da012eac7ae6)


    ***describe one selected module and put the output of terraform graph for this module here***
   
8. Reach YARN UI
   
   ***place the port and the screenshot of YARN UI here***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/fd088579-a464-4b26-b1b1-7cf59d914097)

   
10. Draw an architecture diagram (e.g. in draw.io) that includes:
    1. VPC topology with service assignment to subnets
    2. Description of the components of service accounts
    3. List of buckets for disposal
    4. Description of network communication (ports, why it is necessary to specify the host for the driver) of Apache Spark running from Vertex AI Workbech
  
    ***place your diagram here***

11. Add costs by entering the expected consumption into Infracost

   ***place the expected consumption you entered here***
   https://github.com/mati9456/tbd-2023z-phase1/blob/infracost/infracost-usage.yml

   ***place the screenshot from infracost output here***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/38502f80-cf85-4426-b045-283fed5ed4b2)


11. Some resources are not supported by infracost yet. Estimate manually total costs of infrastructure based on pricing costs for region used in the project. Include costs of cloud composer, dataproc and AI vertex workbanch and them to infracost estimation.

    Rersources not caculated by infracost (shown by running infracost breakdown with --show-skipped flag):
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/6f0be827-53fb-43a6-b54d-a8dfd3b79fb7)

    ***place your estimation and references here***

    ***what are the options for cost optimization?***
    
13. Create a BigQuery dataset and an external table
    
    ***place the code and output here***
   
    ***why does ORC not require a table schema?***
  
14. Start an interactive session from Vertex AI workbench (steps 7-9 in README):

    ***place the screenshot of notebook here***
    ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/891f1345-8492-41b5-ac1f-d1ccdb417cc1)

   
15. Find and correct the error in spark-job.py

    ***describe the cause and how to find the error***

16. Additional tasks using Terraform:

    1. Add support for arbitrary machine types and worker nodes for a Dataproc cluster and JupyterLab instance

    ***place the link to the modified file and inserted terraform code***
    
    3. Add support for preemptible/spot instances in a Dataproc cluster

    ***place the link to the modified file and inserted terraform code***
    
    3. Perform additional hardening of Jupyterlab environment, i.e. disable sudo access and enable secure boot
    
    ***place the link to the modified file and inserted terraform code***

    4. (Optional) Get access to Apache Spark WebUI

    ***place the link to the modified file and inserted terraform code***
