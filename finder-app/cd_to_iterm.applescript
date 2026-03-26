-- cd to iTerm2
-- Finder toolbar app: opens the current Finder directory in iTerm2

on run
    -- Check if iTerm2 is installed
    if not iTerm2IsInstalled() then
        display alert "iTerm2 not found" message "Please install iTerm2 first: https://iterm2.com/" as critical
        return
    end if

    try
        set dirPath to getFinderPath()
    on error errMsg number errNum
        if errNum is -1743 then
            showPermissionDialog()
        else
            display notification "Could not read Finder directory" with title "cd to iTerm2"
        end if
        return
    end try

    if dirPath is missing value then
        display notification "No Finder window found" with title "cd to iTerm2"
        return
    end if

    try
        do shell script "open -a iTerm " & quoted form of dirPath
    on error errMsg number errNum
        if errNum is -1743 then
            showPermissionDialog()
        else
            display alert "cd to iTerm2 error" message errMsg
        end if
    end try
end run

-- Show Automation permission guidance dialog
on showPermissionDialog()
    display dialog "Please grant \"cd to iTerm2\" permission to access Finder." & return & return & "Click \"Open Settings\" to open System Settings → Automation, enable Finder, then try again." buttons {"Cancel", "Open Settings"} default button "Open Settings" with title "Permission Required" with icon caution
    if button returned of result is "Open Settings" then
        do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Automation'"
    end if
end showPermissionDialog

-- Check if iTerm2 is installed
on iTerm2IsInstalled()
    try
        do shell script "open -Ra iTerm"
        return true
    on error
        return false
    end try
end iTerm2IsInstalled

-- Get current Finder directory: prefer selected item, fall back to front window target
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
