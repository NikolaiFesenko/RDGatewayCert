param (
  [Parameter(Mandatory=$true)]
  [string]$Email,

  [Parameter(Mandatory=$true)]
  [string]$Password,

  [Parameter()]
  [string]$CertName = "$Env:ComputerName.$Env:UserDNSDomain"
)

##Checking if the folder exists
$destination_path = "$Env:programfiles\win-acme.v2.1.14.996.x64.pluggable\" 
$search_winacme_folder = Test-Path -Path "$destination_path" 

if ($search_winacme_folder -eq 'True') { 
  Write-Host "The folder $destination_path exists, I launch the program"
}
else { 
  Write-Host "The folder $destination_path does not exist, I'm starting to download"
	
	## Download win-acme.v2.1.14.996.x64.pluggable to user Temp
	$download_url = "https://github.com/win-acme/win-acme/releases/download/v2.1.14.1/win-acme.v2.1.14.996.x64.pluggable.zip" 
	$local_path = "$Env:TMP\win-acme.v2.1.14.996.x64.pluggable.zip" 
	$WebClient = New-Object System.Net.WebClient 
	Write-Host "Download the file $download_url"
	$WebClient.DownloadFile($download_url,$local_path) 
	
	## Unzip win-acme.v2.1.14.996.x64.pluggable into Program Files
	Write-Host "The file has been downloaded to the folder $local_path"
	Write-Host "Let's start unpacking the archive to $destination_path"
	Expand-Archive $local_path -DestinationPath $destination_path
	Write-Host "Delete the archive file."
	Remove-item $local_path 
}

$Cert_path = "Certificats\" 
$search_cert_folder = Test-Path -Path "$destination_path$Cert_path"

if ($search_cert_folder -eq 'True') {
}
else { 
	Write-Host "Create a folder to save certificates."
	New-Item -Path $destination_path$Cert_path -ItemType Directory
}

Write-Host "Certificate name $CertName"

##Checking if the domain name is linked to the site
$DefWebSite = "Default Web Site" ##Variable with the text "Default Web Site" for the procedure (if entered directly, it gives an error)
$Get_Web = Get-WebBinding -Name $DefWebSite -Port 80 -HostHeader $CertName | fl bindingInformation | Out-String 
$Get_Web = $Get_Web.Trim() 

if ("$Get_Web" -eq "bindingInformation : *:80:$CertName") { 
  Write-Host "The site exists"
}
else { 
    Write-Host "The site does not exist. I create."
New-WebBinding -Name $DefWebSite -IPAddress "*" -Port 80 -HostHeader $CertName 
}

$Cert_PathName = "$destination_path$Cert_path$CertName.pfx"
Write-Host "The certificate $Cert_PathName will be created"

cd $destination_path
.\wacs.exe --target manual --siteid 1 --host $CertName --notaskscheduler --emailaddress $Email --accepttos --store pfxfile --pfxfilepath "$Cert_path" --pfxpassword $Password --closeonfinish

Write-Host $LASTEXITCODE
Write-Host $CertName

## Installing a certificate
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
Set-RDCertificate -Role RDRedirector -ImportPath $Cert_PathName -Password $SecurePassword -ConnectionBroker $CertName -Force
Set-RDCertificate -Role RDGateway -ImportPath $Cert_PathName -Password $SecurePassword -ConnectionBroker $CertName -Force
Set-RDCertificate -Role RDWebAccess -ImportPath $Cert_PathName -Password $SecurePassword -ConnectionBroker $CertName -Force
Set-RDCertificate -Role RDPublishing -ImportPath $Cert_PathName -Password $SecurePassword -ConnectionBroker $CertName -Force
