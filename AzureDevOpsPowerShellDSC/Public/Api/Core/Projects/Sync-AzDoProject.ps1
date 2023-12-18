function Sync-AzDoProject {
  <#
.SYNOPSIS
    Gets information about projects in Azure DevOps.
.DESCRIPTION
    Gets information about all the projects in Azure DevOps.
.EXAMPLE
    $Params = @{
        CollectionUri = "https://dev.azure.com/contoso"
        PAT = "***"
    }
    Get-AzDoProject @params

    This example will List all the projects contained in the collection ('https://dev.azure.com/contoso').

.EXAMPLE
    $Params = @{
        CollectionUri = "https://dev.azure.com/contoso"
        PAT = "***"
        ProjectName = 'Project1'
    }
    Get-AzDoProject @params

    This example will get the details of 'Project1' contained in the collection ('https://dev.azure.com/contoso').

.EXAMPLE
    $params = @{
        collectionuri = "https://dev.azure.com/contoso"
        PAT = "***"
    }
    $somedifferentobject = [PSCustomObject]@{
        ProjectName = 'Project1'
    }
    $somedifferentobject | Get-AzDoProject @params

    This example will get the details of 'Project1' contained in the collection ('https://dev.azure.com/contoso').

.EXAMPLE
    $params = @{
        collectionuri = "https://dev.azure.com/contoso"
        PAT = "***"
    }
    @(
        'Project1',
        'Project2'
    ) | Get-AzDoProject @params

    This example will get the details of 'Project1' contained in the collection ('https://dev.azure.com/contoso').
.OUTPUTS
    PSObject with repo(s).
.NOTES
#>
  [CmdletBinding(SupportsShouldProcess)]
  param (
    # Collection Uri of the organization
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string]
    $CollectionUri,

    # Project where the Repos are contained
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [string[]]
    $ProjectName
  )

  begin {
    Write-Verbose "Starting function: Sync-AzDoProject"
  }

  process {
    $project = Get-AzDoProject -CollectionUri $CollectionUri -ProjectName $ProjectName

    if ($PSCmdlet.ShouldProcess($CollectionUri, "Sync Project(s)")) {
      if($project){
        #TODO: Update-AzDoProject
      } else {
        New-AzDoProject -CollectionUri -ProjectName $ProjectName -Confirm:$false
      }

    } else {
      Write-Verbose "Calling Invoke-AzDoRestMethod with $($params| ConvertTo-Json -Depth 10)"
    }
  }
}

