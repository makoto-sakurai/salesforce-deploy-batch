Param(
  [parameter(Mandatory)]$from,
  [parameter(Mandatory)]$to,
  $p = "package.xml",
  [string[]]$tests = @()
)
Write-Host "retrieving..."
$retrieve_result_json = (sfdx force:mdapi:retrieve -u $from -k $p -r . --json) | Out-String
$retrieve_result_json | Out-File retrieve_result.json -encoding UTF8
[int]$retrieve_status = ($retrieve_result_json | jq .status) | Out-String
if ($retrieve_status -ne 0) {
  Write-Host "retrieve error"
  Write-Host $retrieve_result_json
  exit 1
}
$test_command = ''
$tests = [string]::Join(',', $tests)
if ($tests -ne "") {
  $test_command = "--testlevel RunSpecifiedTests --runtests $tests"
}
Write-Host "checking..."
$deploy_check_command = "sfdx force:mdapi:deploy --json -u $to -f unpackaged.zip --checkonly --wait -1 $test_command"
$deploy_check_result_json = (Invoke-Expression $deploy_check_command) | Out-String
$deploy_check_result_json | Out-File deploy_check_result.json -encoding UTF8
[int]$deploy_check_result_status = ($deploy_check_result_json | jq .status) | Out-String
if ($deploy_check_result_status -ne 0) {
  Write-Host "deploy check error"
  Write-Host $deploy_check_result_json
  exit 1
}
# [string]$deploy_check_job_id = ($deploy_check_result_json | jq .result.id) | Out-String
# $deploy_check_job_id = $deploy_check_job_id.Split('"')[1]
# Write-Host "deploying... Job ID: $deploy_check_job_id"
Write-Host "deploying..."
# $deploy_result_json = (sfdx force:mdapi:deploy -q $deploy_check_job_id -u $to -w -1 --json) | Out-String
$deploy_command = $deploy_check_command.Replace(' --checkonly', '')
$deploy_result_json = (Invoke-Expression $deploy_command) | Out-String
[int]$deploy_result_status = ($deploy_result_json | jq .status) | Out-String
if ($deploy_result_status -ne 0) {
  Write-Host "deploy error See deploy_result.json"
} else {
  Write-Host "deploy complete! See deploy_result.json"
}
# Write-Host $deploy_result_json
$deploy_result_json | Out-File deploy_result.json -encoding UTF8
exit 0
