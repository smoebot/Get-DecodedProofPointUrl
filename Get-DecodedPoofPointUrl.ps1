Function Get-DecodedPoofPointUrl {
<#
    .SYNOPSIS
        Supplies encoded URL to ProofPoint API, then retrives decoded URL and relevant associated data
    .DESCRIPTION
        Requires API credentials for ProofPoint TAP
    .PARAMETER encodedUrl
        The encoded URL that was rewritten by ProofPoint.  Needs to be wrapped in double quotes until I work out a way around that
    .INPUTS
        String
    .OUTPUTS
        An object representing the decoded URL and relevant data about the URL
    .NOTES
        Version:        0.1
        Author:         Joel Ashman
        Creation Date:  2020-02-17
        Purpose/Change: Initial script
    .EXAMPLE
        Get-DecodedPoofPointUrl -encodedUrl https://urldefense.proofpoint.com/v2/url?u=https-3A__u15033036.ct.sendgrid.net_ls_click-3Fupn-3D7mW1UGiC9WMvQrTzZHL2IfZsNFXZPZfwnXKK1THVo3tzy0
    #>

param (
    [Parameter(Mandatory=$True,Position=1)]
        [string]$encodedUrl = ""
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12  # Force TLS 1.2 

# Variables for connection to API - Generate API secrets from ProofPoint TAP console
$proofPointServicePrincipal = ''
$proofPointSecret = ''
$creds = "$($proofPointServicePrincipal):$($proofPointSecret)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($creds))
$proofPointApi = "https://tap-api-v2.proofpoint.com/v2/url/decode"
$headers = @{Authorization = "$encodedCreds"}

# Make the API call
$apiResponse = Invoke-restmethod -Headers $headers -Method Post -Body "{`"urls`":[`"$encodedUrl`"]}" -Uri $proofPointApi -ContentType application/json ## Submit the url to ProofPoint

# Needs an error check here in case the API call fails

# Build custom PS object to store and display results
$submittedURLResults = New-Object -TypeName psobject
$submittedURLResults | Add-Member -MemberType NoteProperty -Name encodedUrl -Value $apiResponse.urls.encodedUrl
$submittedURLResults | Add-Member -MemberType NoteProperty -Name recipientEmail -Value $apiResponse.urls.recipientEmail
$submittedURLResults | Add-Member -MemberType NoteProperty -Name decodedUrl -Value $apiResponse.urls.decodedUrl
$submittedURLResults | Add-Member -MemberType NoteProperty -Name success -Value $apiResponse.urls.success
$submittedURLResults | Add-Member -MemberType NoteProperty -Name clusterName -Value $apiResponse.urls.clusterName
$submittedURLResults
}
