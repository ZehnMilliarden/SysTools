class Temperature
{
    [array]GetTemperature() 
    { 
        $t = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" 
        $returntemp = @() 
    
        foreach ($temp in $t.CurrentTemperature) 
        { 
        $currentTempKelvin = $temp/10 
        $currentTempCelsius = $currentTempKelvin - 273.15 
    
        $currentTempFahrenheit = (9/5) * $currentTempCelsius + 32 
    
        $returntemp += $currentTempCelsius.ToString() + " C : " + $currentTempFahrenheit.ToString() + " F : " + $currentTempKelvin + "K" 
        } 
        return $returntemp 
    } 
}


class SysVersion
{
    [string]GetSystemVersion()
    {
        # get instance
        $os = Get-WmiObject Win32_ComputerSystem
        # output information:
        $ret = "The class has {0} properties" -f $os.properties.count
        "Details on this class:"
        Write-Host $os | Format-List *
        return $ret
    }
}

function MainEntry {

    # $Script:temperature = [Temperature]::new()

    # foreach ($value in $Script:temperature.GetTemperature())
    # {
    #    Write-Host $value
    # }

    $Script:systemVersion = [SysVersion]::new()
    $Script:systemVersion.GetSystemVersion()
}

MainEntry