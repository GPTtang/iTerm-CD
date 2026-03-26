-- cd to iTerm2
-- Finder 工具栏 App：点击后在 iTerm2 中打开当前 Finder 目录

on run
    try
        set dirPath to getFinderPath()
        if dirPath is missing value then
            display notification "没有找到 Finder 窗口" with title "cd to iTerm2"
            return
        end if
        -- 用 open 命令打开 iTerm2，无需 Automation 权限控制 iTerm2
        do shell script "open -a iTerm " & quoted form of dirPath

    on error errMsg number errNum
        if errNum is -1743 then
            -- 引导用户授权，点击后直接打开系统设置
            display dialog "请授予「cd to iTerm2」访问 Finder 的权限。" & return & return & "点击「去授权」将打开系统设置 → 自动操作，勾选 Finder 后重试。" buttons {"取消", "去授权"} default button "去授权" with title "需要权限" with icon caution
            if button returned of result is "去授权" then
                do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Automation'"
            end if
        else
            display alert "cd to iTerm2 出错：" & errMsg
        end if
    end try
end run

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
