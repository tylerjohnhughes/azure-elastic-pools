# Create Azure SQL Elastic Pool

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-sql-elasticpools/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-sql-elasticpools/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will create a SQL server with an Elastic Pool. An example database will also be created and added to the pool.

You can modify the array in azuredeploy.json to pull different configurations (Dtu/Storage) for the pricing tier you specify. 
A reference chart showing allowed configurations for each pricing tier is available from Microsoft at: https://azure.microsoft.com/en-us/documentation/articles/sql-database-elastic-pool-reference/

DeploySQLServer_SwitchAzureMode.ps1 will deploy this template for those still running older versions of Azure PowerShell that support Switch-AzureMode.
DeploySQLServer.ps1 will deploy this template for those with current versions of Azure PowerShell.