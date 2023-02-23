function Install-SQLCMD {
    Write-Host "D"
    $Path = $env:TEMP
    $Installer = "vc_redist.x64.exe"
    $URL = "https://aka.ms/vs/15/release/vc_redist.x64.exe"
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Start-Process -FilePath $FullPath -ArgumentList @("/install", "/quiet", "/norestart") -Verb RunAs -Wait
    Remove-Item $Path\$Installer

    $Installer = "msodbcsql.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2223304"
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSODBCSQLLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer

    $Installer = "MsSqlCmdLnUtils.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2142258"
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer
}

Install-SQLCMD

Start-Process -FilePath "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -ArgumentList @("-S sql-0669udh-102.database.windows.net", "-U sqladminuser", "-P ThisIsNotVerySecure!", "-d sqldb0669udh-102", "-Q ""declare @i int = 0; declare @stmt varchar(200); while (@i <= 150000) begin set @i += 1; set @stmt = 'drop table if exists t' + cast(@i as varchar(5)) + '; create table t' + cast(@i as varchar(5)) + '(c1 int, c2 varchar(10), c3 bigint not null)'; exec (@stmt); end""")
