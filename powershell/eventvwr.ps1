# windows ÈÕÖ¾·ÖÎö

class CNtLogEventFilter
{
    hidden $_FilterTable = @{}
    
    [bool]IsTarget([System.Object] $target)
    {
        $Script:Key = $target.Name
        $Script:Value = $target.Value

        if ($Script:Key -eq "Logfile")
        {
            return $true;
        }

        return $this._IsTarget($Script:Key, $Script:Value)
    }

    hidden [bool] _IsTarget([string]$key, $value)
    {

        $Script:bRet = $true;

        do {
        
            if ($this._FilterTable[$key].Count -eq 0)
            {
                break;
            }

            foreach($item in $this._FilterTable[$key])
            {
                if ($item -eq $value)
                {
                    return $Script:bRet
                }
            }
            
            $Script:bRet = $false;

        } while ($false);

        return $Script:bRet;
    }

    DumpFilter()
    {
        foreach($eachItem in $this._FilterTable.keys)
        {
            Write-Host $eachItem,$this._FilterTable[$eachItem]
        }
    }

    AddFilter([string]$key, $value)
    {
        if ($this._FilterTable[$key].Count -gt 0)
        {
            $this._FilterTable[$key]+=$value
        }
        else 
        {
            $this._FilterTable[$key] = @( $value)
        }
    }

    [string] GetLogFile()
    {
        if ($this._FilterTable["Logfile"])
        {
            return $this._FilterTable["Logfile"];
        }

        return "*";
    }
}

class CNtLogEvent
{
    hidden [System.Object]$_NtLogEvent = $null;
    hidden [scriptblock]$_EnumChildCallback = $null;
    hidden [scriptblock]$_EnumChildPropertyCallback = $null;
    hidden [CNtLogEventFilter]$_Filter;
    hidden [int]$_nQueryLimit=100;
    hidden [string]$_strLocalFile="*"
    hidden [bool]$_bNeedLogPropery = $false;

    CNtLogEvent()
    {

    }

    [System.Object]GetInstance()
    {
        if ($null -eq $this._NtLogEvent)
        {
            $Script:strLogFile = $this.GetLogFile()

            $this._NtLogEvent =  Get-CimInstance -Class Win32_NtLogEvent -Namespace "root\CIMV2" | 
            Where-Object{ $_.Logfile -like $Script:strLogFile } | 
            Select-Object -First $this._nQueryLimit
        }

        return $this._NtLogEvent
    }

    SetEnumChildCallback([scriptblock] $callback)
    {
        $this._EnumChildCallback = $callback;
    }

    SetEnumChildPropertyCallback([scriptblock] $callback)
    {
        $this._EnumChildPropertyCallback = $callback;
    }
    
    SetFilter([CNtLogEventFilter] $filter)
    {
        $this._Filter = $filter;
    }

    [string] GetLogFile()
    {
        if ($this._strLocalFile -ne "*")
        {
            return $this._strLocalFile;
        }

        if ($this._Filter)
        {
            return $this._Filter.GetLogFile();
        }

        return $this._strLocalFile;
    }

    SetLogFile([string]$strLogFile)
    {
        $this._strLocalFile = $strLogFile
    }

    SetQueryLimit([int]$limit)
    {
        $this._nQueryLimit = $limit
    }

    [bool]EnumChildObject([System.Object] $object)
    {
        if ($this._EnumChildCallback)
        {
            $this._EnumChildCallback.Invoke($object)
            return $true;
        }

        return $this.EnumChildProperty($object);
    }

    [bool]CheckFilter([System.Object] $object)
    {
        if ($this._Filter)
        {

            foreach($item1 in $object.CimInstanceProperties)
            {
                if ($this._Filter.IsTarget($item1) -eq $false)
                {
                    return $false;
                }
            }

            foreach($item2 in $object.CimClass.CimClassQualifiers)
            {
                if ($this._Filter.IsTarget($item2) -eq $false)
                {
                    return $false;
                }
            }
        }

        return $true;
    }

    [int]EnumChild()
    {
        $Script:nCount = 0;
        foreach ($_NtLogEventItem in $this.GetInstance()) 
        {
            if ($this.EnumChildObject($_NtLogEventItem))
            {
                $Script:nCount++;
            }
        }
        return $Script:nCount;
    }

    AnalysisChildPerProperty([System.Object] $obj)
    {
        if ($this.IsNeedLogProperty())
        {
            Write-Host $obj.Name, "-->>>",$obj.Value
        }
    }

    SetNeedLogProperty([bool] $bValue)
    {
        $this._bNeedLogPropery = $bValue
    }

    [bool]IsNeedLogProperty()
    {
        return $this._bNeedLogPropery;
    }

    [bool]EnumChildProperty([System.Object] $obj)
    {
        if ($this._EnumChildPropertyCallback)
        {
            $this._EnumChildPropertyCallback.Invoke($obj)
            return $true;
        }

        if ($this.CheckFilter($obj) -eq $false)
        {
            return $false;
        }
        
        if ($this.IsNeedLogProperty())
        {
            Write-Host "----------------",$obj.SourceName,"Begin","--------"
        }

        foreach($item1 in $obj.CimInstanceProperties)
        {
            $this.AnalysisChildPerProperty($item1);
        }

        foreach($item2 in $obj.CimClass.CimClassQualifiers)
        {
            $this.AnalysisChildPerProperty($item2);   
        }

        if ($this.IsNeedLogProperty())
        {
            Write-Host "----------------",$obj.SourceName,"End","--------"
        }

        return $true;
    }

}

function MainEntry()
{
    $Script:ntLogFilter = [CNtLogEventFilter]::new()
    $Script:ntLogFilter.AddFilter("Type", "´íÎó")

    $Script:myClass = [CNtLogEvent]::new()
    $Script:myClass.SetQueryLimit(1000)
    $Script:myClass.SetFilter($Script:ntLogFilter)
    $Script:myClass.SetLogFile("Application")
    $Script:myClass.SetNeedLogProperty($true)
    $Script:nRet = $Script:myClass.EnumChild()
}

MainEntry