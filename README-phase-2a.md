IMPORTANT ❗ ❗ ❗ Please remember to destroy all the resources after each work session. You can recreate infrastructure by creating new PR and merging it to master.

![img.png](doc/figures/destroy.png)

0. The goal of this phase is to create infrastructure, perform benchmarking/scalability tests of sample three-tier lakehouse solution and analyze the results using:
* [TPC-DI benchmark](https://www.tpc.org/tpcdi/)
* [dbt - data transformation tool](https://www.getdbt.com/)
* [GCP Composer - managed Apache Airflow](https://cloud.google.com/composer?hl=pl)
* [GCP Dataproc - managed Apache Spark](https://spark.apache.org/)
* [GCP Vertex AI Workbench - managed JupyterLab](https://cloud.google.com/vertex-ai-notebooks?hl=pl)

Worth to read:
* https://docs.getdbt.com/docs/introduction
* https://airflow.apache.org/docs/apache-airflow/stable/index.html
* https://spark.apache.org/docs/latest/api/python/index.html
* https://medium.com/snowflake/loading-the-tpc-di-benchmark-dataset-into-snowflake-96011e2c26cf
* https://www.databricks.com/blog/2023/04/14/how-we-performed-etl-one-billion-records-under-1-delta-live-tables.html

2. Authors:

   ***Enter your group nr***
   Gr.2
   
   ***Link to forked repo***
   https://github.com/mati9456/tbd-2023z-phase1

4. Replace your `main.tf` (in the root module) from the phase 1 with [main.tf](https://github.com/bdg-tbd/tbd-workshop-1/blob/v1.0.36/main.tf)
and change each module `source` reference from the repo relative path to a github repo tag `v1.0.36` , e.g.:
```hcl
module "dbt_docker_image" {
  depends_on = [module.composer]
  source             = "github.com/bdg-tbd/tbd-workshop-1.git?ref=v1.0.36/modules/dbt_docker_image"
  registry_hostname  = module.gcr.registry_hostname
  registry_repo_name = coalesce(var.project_name)
  project_name       = var.project_name
  spark_version      = local.spark_version
}
```


4. Provision your infrastructure.

    a) setup Vertex AI Workbench `pyspark` kernel as described in point [8](https://github.com/bdg-tbd/tbd-workshop-1/tree/v1.0.32#project-setup) 

    b) upload [tpc-di-setup.ipynb](https://github.com/bdg-tbd/tbd-workshop-1/blob/v1.0.36/notebooks/tpc-di-setup.ipynb) to 
the running instance of your Vertex AI Workbench

5. In `tpc-di-setup.ipynb` modify cell under section ***Clone tbd-tpc-di repo***:

   a)first, fork https://github.com/mwiewior/tbd-tpc-di.git to your github organization.

   b)create new branch (e.g. 'notebook') in your fork of tbd-tpc-di and modify profiles.yaml by commenting following lines:
   ```  
        #"spark.driver.port": "30000"
        #"spark.blockManager.port": "30001"
        #"spark.driver.host": "10.11.0.5"  #FIXME: Result of the command (kubectl get nodes -o json |  jq -r '.items[0].status.addresses[0].address')
        #"spark.driver.bindAddress": "0.0.0.0"
   ```
   This lines are required to run dbt on airflow but have to be commented while running dbt in notebook.

   c)update git clone command to point to ***your fork*** https://github.com/mati9456/tbd-tpc-di.

 


6. Access Vertex AI Workbench and run cell by cell notebook `tpc-di-setup.ipynb`.

    a) in the first cell of the notebook replace: `%env DATA_BUCKET=tbd-2023z-9910-data` with your data bucket.


   b) in the cell:
         ```%%bash
         mkdir -p git && cd git
         git clone https://github.com/mwiewior/tbd-tpc-di.git
         cd tbd-tpc-di
         git pull
         ```
      replace repo with your fork. Next checkout to 'notebook' branch.
   
    c) after running first cells your fork of `tbd-tpc-di` repository will be cloned into Vertex AI  enviroment (see git folder).

    d) take a look on `git/tbd-tpc-di/profiles.yaml`. This file includes Spark parameters that can be changed if you need to increase the number of executors and
  ```
   server_side_parameters:
       "spark.driver.memory": "2g"
       "spark.executor.memory": "4g"
       "spark.executor.instances": "2"
       "spark.hadoop.hive.metastore.warehouse.dir": "hdfs:///user/hive/warehouse/"
  ```


7. Explore files created by generator and describe them, including format, content, total size.

   ***Files desccription***
   217 files were generated in the tpc-di folder of the tbd-2023z-303686-data data bucket. Most of the files are octet-stream files with FINWIRE and date naming convention. There are also some plain text, xml and csv files present. Most of these files contain statistical data for processing.
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/50dbeb37-5fec-472c-92a5-fadd818c3300)

9. Analyze tpcdi.py. What happened in the loading stage?

   ***Your answer***
   The tpcdi.py script opens up a Spark session and loads the data from files into 4 databases. Most of the script is for parsing the different file formats and data storage conventions to convert them all into a usable form. 

11. Using SparkSQL answer: how many table were created in each layer?

   ***SparkSQL command and output***
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/83a69f1b-06f8-4a9e-9eeb-32340978f649)


11. Add some 3 more [dbt tests](https://docs.getdbt.com/docs/build/tests) and explain what you are testing. ***Add new tests to your repository.*** 

   ***Code and description of your tests***
   Test 1:
   Checks validity of name, if it contains any numbers
   ```sql
   SELECT *
   FROM {{ ref('dim_broker') }} 
   WHERE first_name IS NOT NULL AND first_name REGEXP '[0-9]'
   ```
  Test 2:
  Checks validity of phone number, if it contains any letters
  ```sql
  SELECT *
  FROM {{ ref('dim_broker') }}
  WHERE phone IS NOT NULL AND phone REGEXP '[a-zA-Z]'
  ```
  Test 3:
  Checks validity of tax, tax is never less than 0
  ```sql
  SELECT *
  FROM  {{ ref('trades') }} 
  WHERE tax < 0
  ```
   ![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/ceff423d-ee75-4275-a63a-7c1f5aca8415)


11. In main.tf update
   ```
   dbt_git_repo            = "https://github.com/mwiewior/tbd-tpc-di.git"
   dbt_git_repo_branch     = "main"
   ```
   so dbt_git_repo points to your fork of tbd-tpc-di. 

12. Redeploy infrastructure and check if the DAG finished with no errors:

***The screenshot of Apache Aiflow UI***
![image](https://github.com/mati9456/tbd-2023z-phase1/assets/23421265/312ed2de-5ac1-4d81-9e4b-0b1fa2fe4da0)

