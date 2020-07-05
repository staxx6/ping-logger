<# 
  title: ping logger
  author: staxx6
  date: 03.04.2020
#>

# Variables
$target = "www.google.de"
$slowPingWarningTime = 30 # in ms
$timeBetweenSeconds = 1
$timeoutSeconds = 1

$startTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$startTimeUnderscore = Get-Date -Format "dd_MM_yyyy HH_mm_ss"
$fileName = "$($startTimeUnderscore) $($target)"
$tracertCount = 3600 # after 3600 pings do a tracert
$pingCount = 0
$outText = ""

# Header
$headerLine = "############################################################################################################"
$headerText = "### Ping Logger ### $($startTime) ### Target: $($target) ### Time between: $($timeBetweenSeconds) s ### Timeout: $($timeoutSeconds) s ###"
$header = "$($headerLine)`r`n$($headerText)`r`n$($headerLine)"

Write-Host $header
$header | Out-File -FilePath .\logs\${fileName}.txt -Append

while ($true) {

  # Tracert
  if(($pingCount % $tracertCount) -eq 0) {
    Write-Host "PingCount reached (or started) doing tracert and write result in file ..."
    $tracertResults = Test-Connection -TargetName www.google.de -IPv4 -Traceroute -TimeoutSeconds 1
    foreach($hop in $tracertResults) {
      $outText = $outText + " # hop $($hop.Hop) $($hop.HostName) pingNr. $($hop.Ping) latency $($hop.Latency) $($hop.Status) `r`n"
    }
    $outText = "Tracert:`r`n$($outText)"
    $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
  }

  # Wait for next pint
  Start-Sleep -Seconds $timeBetweenSeconds

  # ping
  $pingResult = Test-Connection -TargetName www.google.de -IPv4 -Ping -Count 1 -TimeoutSeconds $timeoutSeconds
  $timeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
  $outText = "$timeStamp - $($pingResult.DisplayAddress) $($pingResult.Latency) ms $($pingResult.Status)"

  if ($pingResult.Status -eq "Success") {
    if ($pingResult.Latency -gt $slowPingWarningTime) {
      $outText = $outText + " - Ping SLOW"
    }
  } else {
    $outText = $outText + " - Ping LOST"
  }
  $outText | Out-File -FilePath .\logs\${fileName}.txt -Append
  Write-Host $outText

  $pingCount = $pingCount + 1
}

# Write-Host ((Get-Content .\count.txt | Measure-Object -Line).lines 
# (get-content 'count.txt' | select-string -pattern "PING").length)