function Install-SQLCMD {
    Write-Host "D"
    $Path = $env:TEMP
    $Installer = "vc_redist.x64.exe"
    $URL = "https://aka.ms/vs/15/release/vc_redist.x64.exe"
    Invoke-WebRequest $URL -OutFile $Path\$Installer
    $FullPath = "${Path}\${Installer}"
    Start-Process -FilePath $FullPath -ArgumentList @("/install", "/quiet", "/norestart") -Verb RunAs -Wait
    Remove-Item $Path\$Installer

    $Installer = "msodbcsql.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2223304"
    Invoke-WebRequest $URL -OutFile $Path\$Installer
    $FullPath = "${Path}\${Installer}"
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSODBCSQLLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer

    $Installer = "MsSqlCmdLnUtils.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2142258"
    Invoke-WebRequest $URL -OutFile $Path\$Installer
    $FullPath = "${Path}\${Installer}"
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer
}

Install-SQLCMD
Start-Process -FilePath "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -ArgumentList @("-E", "-S .")
