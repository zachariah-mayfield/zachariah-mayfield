configs = {
"fs.azure.account.auth.type" : "CustomAccessToken",
"fs.azure.account.custom.token.provider.class" : spark.conf.get("spark.databricks.passthrough.adls.gen2.tokenProviderClassName")
}

path_workspace = "/mnt/Company/platform-logs"

containers = ["insights-logs-accounts", "insights-logs-clusters", "insights-logs-databrickssql", "insights-logs-dbfs", "insights-logs-deltapipelines", "insights-logs-featurestore", "insights-logs-jobs", "insights-logs-mlflowacledartifact", "insights-logs-mlflowexperiment", "insights-logs-modelregistry", "insights-logs-notebook", "insights-logs-remotehistoryservice", "insights-logs-repos", "insights-logs-secrets", "insights-logs-sqlanalytics", "insights-logs-sqlpermissions", "insights-logs-ssh", "insights-logs-workspace"]

for container in containers:
    
    dbutils.fs.unmount(path_workspace)
                   
    if not any(mount.mountPoint == path_workspace for mount in dbutils.fs.mounts()):
        dbutils.fs.mount(
        source = (f'abfss://{container}@databricksdevauditlogs.dfs.core.windows.net/'),
        #print(source)
        mount_point = path_workspace,
        extra_configs = configs
        )
    recursive_loaded_df = spark.read.format("json")\
    .option("recursiveFileLookup", "true")\
    .load(path_workspace)
    recursive_loaded_df.show()
    
    # Platform audit logs 
    # Writing view to delta table
    table_name = container.split('-')[-1]
    recursive_loaded_df.write.format('delta').mode("append").saveAsTable(f'platformlogs.{table_name}')
