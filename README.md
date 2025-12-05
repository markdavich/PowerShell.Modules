# Bops Lib!

## Profiles

1. All default (user) profiles move to `.\Profiles\Users\[UserName]` (**A**)
2. All default profiles are replaced with a corresponding profile  
   found here: `.\Profiles\c.users.username.documents.PowerShell` (**B**)
3. Each **B** calls `.profile` (**C**), **C** calls **A**

> All **B** level profiles should call the default PowerShell 7 User Profile:  
>   `Microsoft.PowerShell_profile.ps1`



## Settings
### Visual Studio
`"$env:LOCALAPPDATA\Microsoft\VisualStudio\17.0_b2d1ddb7\settings\CurrentSettings.vssettings"`
```xml
<UserSettings>
    <ApplicationIdentity version="17.0"/>
    <ToolsOptions>
        <ToolsOptionsCategory name="Environment" RegisteredName="Environment">
            <ToolsOptionsSubCategory name="ProjectsAndSolution" RegisteredName="ProjectsAndSolution" PackageName="Visual Studio Environment Package">
                <PropertyValue name="ProjectsLocation">%vsspv_user_appdata%\source\repos</PropertyValue>
            </ToolsOptionsSubCategory>
        </ToolsOptionsCategory>
    </ToolsOptions>
</UserSettings>
```
Can you write me a PowerShell script that sets the ProjectsLocation