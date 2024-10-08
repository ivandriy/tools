function Get-TimeStamp {
    "[{0:MM/dd/yy} {0:HH:mm:ss:ffff}]" -f (Get-Date)
  }
  
  function Write-Log
  {
  Param (
    [Parameter(Mandatory = $false)]
    [string]
    $LogString,

    [Parameter(Mandatory = $false)]
    [string]
    $LogFile
    )

    if($LogString){
        Write-Host $LogString

        if($LogFile){
            Add-content $LogFile -value $LogString
          } 
    }
  }
  
  function Get-ApiRequest {
      param (
        [Parameter(Mandatory = $true)]
        [string]
        $Uri,
  
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Headers
      )
  
      $result = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
      return $result

    }
  
    function Patch-ApiRequest {
      param (
        [Parameter(Mandatory = $true)]
        [string]
        $Uri,
  
        [Parameter(Mandatory = $false)]
        [string]
        $Body,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Headers
      )
  
      $result = Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers -Body $Body -ContentType 'application/json'
      return $result
    }
    
    function Post-ApiRequest {
      param (
        [Parameter(Mandatory = $true)]
        [string]
        $Uri,
  
        [Parameter(Mandatory = $false)]
        [string]
        $Body,
  
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Headers
      )
  
      $result = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body -ContentType 'application/json'
      return $result
    }

    function Put-ApiRequest {
      param (
        [Parameter(Mandatory = $true)]
        [string]
        $Uri,
  
        [Parameter(Mandatory = $false)]
        [string]
        $Body,
  
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Headers
      )
  
      $result = Invoke-RestMethod -Uri $Uri -Method Put -Headers $Headers -Body $Body -ContentType 'application/json'
      return $result
    }
    
    function Delete-ApiRequest {
      param (
        [Parameter(Mandatory = $true)]
        [string]
        $Uri,
  
        [Parameter(Mandatory = $false)]
        [string]
        $Body,
  
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Headers
      )
  
      $result = Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Headers -Body $Body -ContentType 'application/json'
      return $result
    } 

    Export-ModuleMember -Function Get-TimeStamp,Write-Log,Get-ApiRequest,Patch-ApiRequest,Post-ApiRequest,Put-ApiRequest,Delete-ApiRequest