# Windows 工具

. "./eventvwr.ps1"

function MainEntry()
{
    $Script:ntLogFilter = [CNtLogEventFilter]::new()
    $Script:ntLogFilter.AddFilter("Type", "错误")

    $Script:myClass = [CNtLogEvent]::new()
    $Script:myClass.SetQueryLimit(1000)
    $Script:myClass.SetFilter($Script:ntLogFilter)
    $Script:myClass.SetLogFile("System")
    $Script:myClass.SetNeedLogProperty($true)
    $Script:nRet = $Script:myClass.EnumChild()

}

MainEntry