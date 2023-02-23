
# init log setting
$logLoc = "$env:SystemDrive\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\"
if (! (Test-Path($logLoc)))
{
    New-Item -path $logLoc -type directory -Force
}
$logPath = "$logLoc\tracelog.log"
"Start to execute SQLCMDInstall.ps1. `n" | Out-File $logPath

function Now-Value()
{
    return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function Throw-Error([string] $msg)
{
	try 
	{
		throw $msg
	} 
	catch 
	{
		$stack = $_.ScriptStackTrace
		Trace-Log "DMDTTP is failed: $msg`nStack:`n$stack"
	}

	throw $msg
}

function Trace-Log([string] $msg)
{
    $now = Now-Value
    try
    {
        "$now $msg`n" | Out-File $logPath -Append
    }
    catch
    {
        #ignore any exception during trace
    }

}

function Install-SQLCMD {
    $Path = $env:TEMP
    $Installer = "vc_redist.x64.exe"
    $URL = "https://aka.ms/vs/15/release/vc_redist.x64.exe"
    Trace-Log "Initiating Download of VC Runtime."
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Trace-Log "Initiating Installation of VC Runtime."
    Start-Process -FilePath $FullPath -ArgumentList @("/install", "/quiet", "/norestart") -Verb RunAs -Wait
    Remove-Item $Path\$Installer

    $Installer = "msodbcsql.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2223304"
    Trace-Log "Initiating Download of Microsoft SQL Server ODBC Driver."
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Trace-Log "Initiating Installation of Microsoft SQL Server ODBC Driver."
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSODBCSQLLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer

    $Installer = "MsSqlCmdLnUtils.msi"
    $URL = "https://go.microsoft.com/fwlink/?linkid=2142258"
    Trace-Log "Initiating Download of SQLCMD Utility."
    Invoke-WebRequest $URL -OutFile $Path\$Installer -UseBasicParsing
    $FullPath = "$Path\$Installer"
    Trace-Log "Initiating Installation of SQLCMD Utility."
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", ('"{0}"' -f $FullPath), "/qn", "IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES") -Verb RunAs -Wait
    #Remove-Item $Path\$Installer
}

Trace-Log "Initiating Download - Install sequence."
Trace-Log "Log file: $logLoc"
Install-SQLCMD
Trace-Log "Launching SQLCMD to create 150000 tables."
Start-Process -FilePath "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -ArgumentList @("-S sql-adl-nonsecured.database.windows.net", "-U sqladminuser", "-P ThisIsNotVerySecure!", "-d sqldbadl-nonsecured", "-Q ""declare @i int = 1; declare @stmt varchar(2000); while (@i <= 150000) begin set @i += 1; set @stmt = 'drop table if exists t' + cast(@i as varchar(10)) + '; create table t' + cast(@i as varchar(10)) + '(c1 int IDENTITY(1,2), c2 varchar(10), c3 bigint not null, c4 bit, c5 datetime2, c6 time, c7 nchar(10), c8 tinyint, c9 decimal, c10 char(25), c11 datetimeoffset, c12 varbinary(100), c13 smalldatetime, c14 date, c15 float, c16 money)'; exec (@stmt); end""", "-o $logLoc\SQLCMD.log") -RedirectStandardOutput $logLoc\stdout.log -RedirectStandardError $logLoc\stderr.log -Wait
Trace-Log "Finished."
