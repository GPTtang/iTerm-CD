-- cd to iTerm2
-- Finder 工具栏 App：点击后在 iTerm2 中打开当前 Finder 目录

on run
    -- 检查 iTerm2 是否安装
    if not iTerm2IsInstalled() then
        display alert "未找到 iTerm2" message "请先安装 iTerm2：https://iterm2.com/" as critical
        return
    end if

    try
        set dirPath to getFinderPath()
    on error
        display notification "无法读取 Finder 目录" with title "cd to iTerm2"
        return
    end try

    if dirPath is missing value then
        display notification "没有找到 Finder 窗口" with title "cd to iTerm2"
        return
    end if

    try
        do shell script "open -a iTerm " & quoted form of dirPath
    on error errMsg number errNum
        if errNum is -1743 then
            display dialog "请授予「cd to iTerm2」访问 Finder 的权限。" & return & return & "点击「去授权」将打开系统设置 → 自动操作，勾选 Finder 后重试。" buttons {"取消", "去授权"} default button "去授权" with title "需要权限" with icon caution
            if button returned of result is "去授权" then
                do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Automation'"
            end if
        else
            display alert "cd to iTerm2 出错" message errMsg
        end if
    end try
end run

-- 检查 iTerm2 是否安装
on iTerm2IsInstalled()
    try
        do shell script "open -Ra iTerm"
        return true
    on error
        return false
    end try
end iTerm2IsInstalled

-- 获取当前 Finder 目录：优先用选中项，否则用窗口目标
on getFinderPath()
    tell application "Finder"
        set sel to selection
        if (count of sel) > 0 then
            set selItem to item 1 of sel
            if class of selItem is folder then
                return POSIX path of (selItem as alias)
            else
                return POSIX path of ((container of selItem) as alias)
            end if
        end if
        if (count of Finder windows) > 0 then
            return POSIX path of (target of front Finder window as alias)
        end if
    end tell
    return missing value
end getFinderPath
