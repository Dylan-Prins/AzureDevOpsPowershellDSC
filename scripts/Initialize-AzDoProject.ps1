[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $CollectionUri = "https://dev.azure.com/dylanprins/",

  [Parameter(mandatory)]
  [string]
  $Path
)
$informationPreference = 'Continue'
$ConfirmPreference = 'None'

$organization = Get-Content -Path $path | ConvertFrom-Json -Depth 10

$organization.projects | ForEach-Object {
  Write-Information "Adding projects"
  $project = New-AzDoProject -CollectionUri $CollectionUri -ProjectName $_.name

  $_.repos | ForEach-Object {
    Write-Information "Adding repos"
    $repo = New-AzDoRepo -CollectionUri $CollectionUri -ProjectName $project.ProjectName -RepoName $_.name
    if (-not($null -eq $_.filesPath)) {
      Write-Information "Adding files to repo"
      $fileLocation = (Get-Item -Path $path).Directory.FullName
            ((Join-Path -Path $fileLocation -ChildPath $_.filesPath) | Resolve-Path).FullName
      $repo | Add-FilesToRepo -Path ((Join-Path -Path $fileLocation -ChildPath $_.filesPath) | Resolve-Path).path

      $_.pipelines | ForEach-Object {
        Write-Information "Adding pipelines"
        $pipeline = $repo | New-AzDoPipeline -PipelineName $_.name -Path $_.path
        if($_.buildValidation) {
          Write-Information "Setting pipeline as Build validation"
          $repo | Set-AzDoBranchPolicyBuildValidation -Id $pipeline.PipelineId
        }
      }

      Write-Information "Setting comment resolution"
      $repo | Set-AzDoBranchPolicyCommentResolution

      Write-Information "Setting Merging strategy"
      $repo | Set-AzDoBranchPolicyMergeStrategy

      Write-Information "Setting Minimal approval"
      $repo | Set-AzDoBranchPolicyMinimalApproval
    }
  }

  Write-Information "Adding environments"
  $_.environments | ForEach-Object {
    $environments = $project | New-AzDoEnvironment -EnvironmentName $_.name
    if($_.branchControl.enabled -eq $true){
      Write-Information "Setting branch control"
      $environments | Add-AzDoPipelineBranchControl -ResourceType environment -resourceName $_.name
    }
  }
}

# $ErrorActionPreference = 'stop'
# $path = ".\" | Resolve-Path

# $project = New-AzDoProject -CollectionUri $CollectionUri -ProjectName $projectName -Confirm:$false
# $project | New-AzDoEnvironment -EnvironmentName "TestEnvironment" -Confirm:$false

# #TODO: not working yet
# #Set-AzDoPipelineBranchControl -CollectionUri $CollectionUri -ProjectName $projectName -ResourceType environment -resourceName "TestEnvironment"

# $repo = New-AzDoRepo -CollectionUri $CollectionUri -ProjectName $projectName -RepoName "TestRepo" -Confirm:$false
# $repo | Add-FilesToRepo -path $path -confirm:$false

# $pipeline = $repo | New-AzDoPipeline -PipelineName "TestRepo" -Confirm:$false
# $repo | Set-AzDoBranchPolicyBuildValidation -Id $pipeline.PipelineId -Confirm:$false
# $repo | Set-AzDoBranchPolicyCommentResolution -Confirm:$false
# $repo | Set-AzDoBranchPolicyMergeStrategy -Confirm:$false
# $repo | Set-AzDoBranchPolicyMinimalApproval -Confirm:$false
