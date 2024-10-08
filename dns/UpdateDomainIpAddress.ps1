param(
    [switch]
    $UseLanet,

    [switch]
    $UseSimnet
)

#region Functions
function Update-Dns {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Ip
    )
    $configuration.Domains|ForEach-Object{
        $domain = $_
        Write-Log "$(Get-TimeStamp) Updating domain $($domain) records"
        
        $getDomainRecordsAUri = $configuration.ApiUrl + $getDomainRecordsA.Replace('{domain}',$domain)
        $getDomainRecordsTxtUri = $configuration.ApiUrl + $getDomainRecordsTxt.Replace('{domain}',$domain)
        $aRecords = Get-ApiRequest -Uri $getDomainRecordsAUri -Headers $headers
        $txtRecords = Get-ApiRequest -Uri $getDomainRecordsTxtUri -Headers $headers
        $aRecords.domain_records|ForEach-Object{
            $record = $_
            Write-Log "$(Get-TimeStamp) Try to update A record id: '$($record.id)', name: '$($record.name)', current value: '$($record.data)', new value: '$($ip)'"
            $patchRecordUri = $configuration.ApiUrl + $patchDomainRecord.Replace('{domain}',$domain).Replace('{id}',$record.id)
            $patchBody =@{
                data = $ip
            }
            $patchBodyRequest = $patchBody|ConvertTo-Json
            $updatedRecord = Patch-ApiRequest -Uri $patchRecordUri -Body $patchBodyRequest -Headers $headers
            Write-Log "$(Get-TimeStamp) Updated A record id: '$($updatedRecord.id)', name: '$($updatedRecord.name)', value: '$($updatedRecord.data)'"

        }
        $txtRecords.domain_records|Where-Object -Property data -Match $spfIpPattern|ForEach-Object{
            $record = $_
            $matched = $record.data -match $spfIpPattern
            if($matched){
                $replacement = "$($Matches[1])$($ip)$($Matches[3])"
                $updatedSpf = $record.data -replace $spfIpPattern,$replacement
                Write-Log "$(Get-TimeStamp) Try to update TXT record id: '$($record.id)', name: '$($record.name)', current value: '$($record.data)', new value: '$($updatedSpf)'"
                $patchRecordUri = $configuration.ApiUrl + $patchDomainRecord.Replace('{domain}',$domain).Replace('{id}',$record.id)
                $patchBody =@{
                    data = $updatedSpf
                }
                $patchBodyRequest = $patchBody|ConvertTo-Json
                $updatedRecord = Patch-ApiRequest -Uri $patchRecordUri -Body $patchBodyRequest -Headers $headers
                Write-Log "$(Get-TimeStamp) Updated TXT record id: '$($updatedRecord.id)', name: '$($updatedRecord.name)', value: '$($updatedRecord.data)'"
            }
        }
    }
    
}
#endregion

Import-Module ../modules/Functions.psm1 -DisableNameChecking -Force

$startTime = $(get-date)
$timestampDate = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$currentDir = $PSScriptRoot
$logName = "UpdateDomainIpAddress_$($timestampDate).txt"
$logfile = Join-Path $currentDir $logName

Write-Log "$(Get-TimeStamp) Script started"

$configFile = 'config.json'
$configFilePath = Join-Path $currentDir $configFile
if (!(Test-Path $configFilePath)) {
    Write-Error "Config file not found by path '$($configFilePath)'"
    return
}
$configuration=Get-Content -Path $configFilePath | ConvertFrom-Json

$getDomainRecordsA = '/domains/{domain}/records?type=A'
$getDomainRecordsTxt = '/domains/{domain}/records?type=TXT'
$patchDomainRecord = '/domains/{domain}/records/{id}'
$spfIpPattern = '^(v=spf1 ip4:)(\d+\.\d+\.\d+\.\d+)( -all)'
$headers = @{
    'Authorization' = "Bearer $($configuration.Token)"
}

if($UseLanet){
    $ip = $configuration.IpAddresses.Lanet
    Write-Log "$(Get-TimeStamp) Using Lanet ip $($ip) to update DNS records"
    Update-Dns $ip
}

if($UseSimnet){
    $ip = $configuration.IpAddresses.SimNet
    Write-Log "$(Get-TimeStamp) Using SimNet ip $($ip) to update DNS records"
    Update-Dns $ip
}

$elapsedTime = $(get-date) - $startTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
Write-Log "$(Get-TimeStamp) Total time: $($totalTime)"
Write-Log "$(Get-TimeStamp) Script finished"