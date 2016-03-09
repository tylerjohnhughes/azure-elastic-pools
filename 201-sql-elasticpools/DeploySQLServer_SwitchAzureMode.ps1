param(
    [CmdletBinding()]
    [Parameter(Mandatory=$true)] [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)] [string]$ResourceGroupLocation,
    [Parameter(Mandatory=$true)] [string]$AzureARMTemplate,
    [Parameter(Mandatory=$true)] [string]$AzureARMTemplateParameters,
    [Parameter(Mandatory=$true)] [string]$SQLServerPassword,
    [Parameter(Mandatory=$false)] [string]$AzureSubscriptionName = "",
    [Parameter(Mandatory=$false)] [string]$StorageAccountName
)


function New-ParameterObject{
    <#
	.SYNOPSIS	
	    Create a hash table from a parameters file
	.DESCRIPTION
        This function takes in the ARM template and parameters file. It will return a hash table
        containing only values from the parameters file that both exist in the ARM template and
        are not null in value. This hash table is used as ParameterObject in the 
        New-AzureResourceGroupDeployment cmdlet.
	.PARAMETER TemplateFilePat
	    The file path to the ARM template json file.
	.PARAMETER ParameterFilePath
        The file path to the parameters json file.
	.EXAMPLE
	    New-ParameterObject -TemplateFilePath "C:\Templates\azuredeploy.json -ParameterFilePath "C:\Templates\azuredeploy.parameters.json"
	.EXAMPLE
	    New-ParameterObject -TemplateFilePath "C:\ARMTemplates\azuredeploy.json -ParameterFilePath "C:\ARMTemplates\azuredeploy.parameters.json" -Verbose
	#>
    param(
        [CmdletBinding()]
        [Parameter(Mandatory=$true)] [string]$TemplateFilePath,
        [Parameter(Mandatory=$true)] [string]$ParameterFilePath
    )

    Write-Verbose ("Using template file at path: " + $TemplateFilePath)
    Write-Verbose ("Using parameter file at path: " + $ParameterFilePath)
    
    #Initialize our hash table
    $HashTable = @{}

    #Pull our parameters out of the ARM template file and into an array
    $TemplateParameters = (((Get-Content $TemplateFilePath -Raw | ConvertFrom-Json).parameters | Get-Member | WHERE {$_.MemberType -eq 'NoteProperty'}).Name)
    $ParametersFile = ([string](Get-Content $ParameterFilePath) | ConvertFrom-Json).parameters
    
    #Compare each parameter in our template to the parameters in the parameter file.
    #If the parameter in the parameter file is not null, then we can add that parameters
    #name and value to our hashtable.
    ForEach($Parameter in $TemplateParameters){
        
        if($ParametersFile.$($Parameter) -ne $null){
            $HashTable += @{$Parameter = $ParametersFile.$($Parameter).value}
            Write-Verbose ("Added parameter $Parameter with value " + $ParametersFile.$($Parameter).value)
        }
    }

    #Return the hash table
    return $HashTable
}

#Make sure our storage account exists. If not, create it.
if(!(Test-AzureName -Storage $StorageAccountName)){
    New-AzureStorageAccount -StorageAccountName $StorageAccountName -Location $ResourceGroupLocation
}

#Change the Azure PowerShell mode to Resource Manager
Switch-AzureMode AzureResourceManager

#Check if the resource group already exists. If not, create it.
if(-not (Test-AzureResourceGroup -ResourceGroupName $ResourceGroupName )) {
    New-AzureResourceGroup -Name $ResourceGroupName  -Location $ResourceGroupLocation
}

#We need to convert the password to a secure string and pass it to the New-AzureResourceGroupDeployment
#cmdlet since that parameter is null in the parameters json file.
$SecurePassword = ConvertTo-SecureString $SQLServerPassword -AsPlainText -Force

#This function will take our parameters file and return a hash table of parameters that are not null in value.
$ParameterObject = New-ParameterObject -TemplateFilePath $AzureARMTemplate -ParameterFilePath $AzureARMTemplateParameters

#Deploy the template to the resource group using the ARM template and the parameters hash.
New-AzureResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $AzureARMTemplate -TemplateParameterObject $ParameterObject -StorageAccountName $StorageAccountName -sqlAdministratorLoginPassword $SecurePassword -Verbose


#.\DeploySQLServer_SwitchAzureMode.ps1 -ResourceGroupName "BMO01" -ResourceGroupLocation "East US" -AzureARMTemplate ".\azuredeploy.json" -AzureARMTemplateParameters ".\azuredeploy.parameters.json" -SQLServerPassword 'Pa$$w0rd' -StorageAccountName "ngpvanbmo01store"