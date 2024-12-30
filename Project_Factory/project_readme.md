# Data Engineering Project

## Dataset
- sales_dataset.csv
- Primary Keys: `branch_id, dealer_id, model_id`


## Project Steps Flow:
- Azure Data Factory [`Data Ingestion`: SQL source, or csv or else]
- Azure Databricks [`Transformations`: Raw data (parquet format, mostly incremental dataset) -> Transformed data (parquet format, mostly the one big table) -> serving data (delta lake, data govbernance, mostly the STAR schema) on Data Lake Gen2]
    - Bronze Layer: Raw data
    - Silver Layer: Transformed data
    - Gold Layer: Serving data
- Fact, Dimensions
- Incremental Data: updating new data (eg: last 30 days data, last 7 days data etc)
- Pyspark

## Steps:
- MS Azure: 
    - [Resource Group] Create a `resource group` to source the data into SQL database - named it <data_eng_project>
    - [Storage Account- Data Lake creation] Click create on resource group and search for storage account <carcompanydatalake> Data Lake Gen2
        - Create Data Storage containers for each layer: <bronze>, <silver>, <gold>
    - [Azure Data Factory] create a data factory <carsalesfactory>
        - Create Pipleline <source_prep_pipeline> to fetch data from source to destination [Eg: Github -> ADF -> SQL]. We use copy activity to migrate data from source to destination. It called `Linked Service` to do that. Mangage Tab -> Linked Services -> HTTP connection (for github repo) -> 
        - Use same pipleline for incremental data as well.
        - Then build data warehouse pipeline which is the STAR schema
    - [Azure SQL Database] create a SQL database <carsalesdb>
    - [Azure server] create a server <cardataprojectserver>, created source to destination sql database query


## Accounts:
- [Azure Portal Account](https://portal.azure.com/)