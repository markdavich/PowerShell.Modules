
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