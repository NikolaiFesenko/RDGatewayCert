# RDGatewayCert
This PowerShell script is designed to automate the update of the Remote Desktop Gateway certificate in the Windows operating system. It checks for the existence of a folder containing the program win-acme.v2.1.14.996.x64.pluggable in the Program Files directory. If the specified folder is missing, the script downloads win-acme version 2.1.14.996 from the GitHub repository and extracts it.

After unpacking win-acme, the script requests a new SSL certificate through win-acme to ensure a secure connection on the server. The obtained certificate is then installed for both the website and the MS RD Gateway Remote Desktop Gateway, providing a secure and protected connection for users.

To automate the script execution, pass the following parameters to it:
.\RDGatewayCert.ps1 -Password "qwe123" -Email "name@mail.com" -CertName "gateway.example.com"

The CertName parameter is optional, and if it is absent, the full computer domain name will be used.
