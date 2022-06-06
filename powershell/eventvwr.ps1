# windows 事件查看器

function Text
{
    param
    (
        [System.Object]$TestTxt
    )

    Write-Host $TestTxt.ToString()
}

class CNtLogEvent
{
    [System.Object]$_NtLogEvent;
    [scriptblock]$_Callback;
 
    CNtLogEvent()
    {
        $this._NtLogEvent = Get-CimInstance -Class Win32_Group
    }

    SetCallback([scriptblock] $callback)
    {
        $this._Callback = $callback;
    }
    
    EnumChild()
    {
        for ($index = 0; $index -lt $this._NtLogEvent.Count; $index++ )
        {
            $_NtLogEventItem =  $this._NtLogEvent.Get($index)

            if ($this._Callback)
            {
                $this._Callback.Invoke($_NtLogEventItem)
            }
        }
    }
}


$myClass = [CNtLogEvent]::new()
$myClass.SetCallback(${Function::Text})
$myClass.EnumChild()