<# 
  title: ping logger
  author: staxx6
  date: 03.04.2020
#>

# Variables
$target = "www.google.de"
$slowPingWarningTime = 30 # in ms
$timeBetweenSeconds = 1
$tracertAtLost = $false
$timeoutSeconds = 1

$startTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$startTimeUnderscore = Get-Date -Format "dd_MM_yyyy HH_mm_ss"
$fileName = "$($startTimeUnderscore) $($target)"
$tracertCount = 3600 # after 3600 pings do a tracert
$pingCount = 0

# Header
$headerLine = "############################################################################################################"
$headerText = "### Ping Logger ### $($startTime) ### Target: $($target) ### Time between: $($timeBetweenSeconds) s ### Timeout: $($timeoutSeconds) s ###"

Write-Host $headerLine
Write-Host $headerText
Write-Host $headerLine

$headerLine | Out-File -FilePath .\logs\${fileName}.txt -Append
$headerText | Out-File -FilePath .\logs\${fileName}.txt -Append
$headerLine | Out-File -FilePath .\logs\${fileName}.txt -Append

while ($true) {

  if(($pingCount % $tracertCount) -eq 0) {
    Write-Host "PingCount reached (or started) doing tracert and write it in file ..."
    $tracertResults = Test-Connection -TargetName www.google.de -IPv6 -Traceroute -TimeoutSeconds 1 # Array kommt da raus
    foreach($hop in $tracertResults) {
      $outText = $outText + " # $($hop.Hop) $($hop.HostName) $($hop.Ping) $($hop.Latency) $($hop.Status)"
    }
    $outText = "Tracert: $($outText)"
    $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
  }
  $pingCount = $pingCount + 1

  Start-Sleep -Seconds $timeBetweenSeconds
  $pingResult = Test-Connection -TargetName www.google.de -IPv6 -Ping -Count 1 -TimeoutSeconds $timeoutSeconds
  $timeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
  $outText = ""

  if ($pingResult.Status -eq "Success") {
    if ($pingResult.Latency -gt $slowPingWarningTime) {
      $outText = "$timeStamp - $($pingResult.DisplayAddress) $($pingResult.Latency) ms $($pingResult.Status) - Slow ping"
    } else {
      $outText = "$timeStamp - $($pingResult.DisplayAddress) $($pingResult.Latency) ms $($pingResult.Status)"
    }
    $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
    Write-Host $outText
  } else {
    if($tracertAtLost) {
      $outText = "Ping lost - tracert:"
      Write-Host $outText
      $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
  
      $tracertResults = Test-Connection -TargetName www.google.de -IPv6 -Traceroute -TimeoutSeconds 1 # Array kommt da raus
      foreach($hop in $tracertResults) {
        $outText = $outText + " # $($hop.Hop) $($hop.HostName) $($hop.Ping) $($hop.Latency) $($hop.Status)"
      }
      Write-Host "-> Output in file"
      "$($timeStamp) - $($outText)" | Out-File -FilePath .\logs\${fileName}.txt -Append
    } else {
      $outText = "$timeStamp - $($pingResult.DisplayAddress) $($pingResult.Latency) ms $($pingResult.Status) - Ping LOST"
      $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
      Write-Host $outText
    }
  }
}