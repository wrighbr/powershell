$Volumes = Get-WmiObject win32_volume | Where-Object {$_.Label -eq 'User Disk'} # | fl *
$Disks = @()
$Nagios = 0
$WarningLevel = 15
$CriticalLevel = 5
$Notify = 'OK'

$Volumes | ForEach-Object {

    $Object = New-Object PSObject -Property @{
    
    Name            = $_.name
    'Capacity(GB)'  = [math]::Round($_.Capacity/'1073741824',2)
    'FreeSpace(GB)' = [math]::Round($_.Freespace/'1073741824',2)
    'Free(%)'       = [math]::Round($_.Freespace/$_.Capacity*'100',0)
    
    }
    
    $Disks += $Object
} 

$Disks | ForEach-Object {
    
    if($_.'Free(%)' -le $WarningLevel -and $_.'Free(%)' -gt $CriticalLevel){
        if($Nagios -ne 2){
            $Nagios = 1
            $Notify = 'WARNING'
            }
        }
    if($_.'Free(%)' -le $CriticalLevel){
        $Nagios = 2
        $Notify = 'CRITICAL'
    }
}

Write-Host 'RDS Users Profile Space is at' $Notify 'Levels'
$Disks | Where-Object {$_.'Free(%)' -le $WarningLevel}| Sort-Object 'Free(%)' | Format-Table Name, 'Capacity(GB)', 'FreeSpace(GB)', 'Free(%)' -AutoSize

exit $Nagios
