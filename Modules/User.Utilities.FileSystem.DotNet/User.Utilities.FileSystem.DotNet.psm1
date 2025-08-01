using namespace System.IO
using module User.Implementations.Parser.Directive.Aspx
using module User.Implementations.Parser.Attribute.Markup

function Copy-CodeBehindWithMatchingName {
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$View,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$CodeBehind,

        [Parameter(Mandatory)]
        [string]$OutputFolder
    )

    # Step 1: Extract components
    $baseName = $View.BaseName # e.g., PF_Login
    $viewExt = $View.Extension.TrimStart('.')  # e.g., aspx
    $codeExt = $CodeBehind.Extension.TrimStart('.')  # e.g., cs

    # Step 2: Build new filename
    $newFileName = "$baseName.$viewExt.$codeExt"

    # Step 3: Copy to output
    $destinationPath = Join-Path $OutputFolder $newFileName
    Copy-Item -Path $CodeBehind.FullName -Destination $destinationPath -Force

    return [FileSystemInfo](Get-Item $destinationPath)
}

function Get-ClassDefinitionMap {
    param (
        [string]$Root = "."
    )

    $classMap = @{}

    $csprojFiles = Get-ChildItem -Path $Root -Recurse -Filter *.csproj

    foreach ($csproj in $csprojFiles) {
        $projPath = $csproj.FullName
        $projDir = Split-Path $projPath

        $csFiles = Get-ChildItem -Path $projDir -Recurse -Filter *.cs

        foreach ($file in $csFiles) {
            $namespace = $null
            $content = Get-Content $file.FullName

            foreach ($line in $content) {
                if (-not $namespace -and $line -match '^\s*namespace\s+([\w\.]+)') {
                    $namespace = $matches[1]
                }

                if ($line -match '^\s*(public|internal)?\s*(partial\s+)?class\s+(\w+)\b') {
                    $className = $matches[3]
                    $fullName = if ($namespace) { "$namespace.$className" } else { $className }

                    if (-not $classMap.ContainsKey($fullName)) {
                        $classMap[$fullName] = @()
                    }

                    $classMap[$fullName] += $projPath
                }
            }
        }
    }

    return $classMap
}

function Get-CsFilesInProject {
    param (
        [string]$ProjectPath
    )

    [xml]$xml = Get-Content $ProjectPath
    $ns = New-Object System.Xml.XmlNamespaceManager $xml.NameTable
    $ns.AddNamespace("msb", $xml.Project.NamespaceURI)

    $projectDir = Split-Path $ProjectPath
    $files = @()

    $xml.SelectNodes("//msb:Compile", $ns) | ForEach-Object {
        $include = $_.Include
        if ($include -and $include.EndsWith(".cs")) {
            $fullPath = Join-Path $projectDir $include
            $resolved = Resolve-Path -Path $fullPath -ErrorAction SilentlyContinue
            if ($resolved) {
                $files += $resolved.Path
            }
        }
    }

    return $files
}

function Get-AllProjectFileMap {
    param (
        [string]$Root = "."
    )

    $map = @{}
    $csprojs = Get-ChildItem -Path $Root -Recurse -Filter *.csproj

    foreach ($proj in $csprojs) {
        $files = Get-CsFilesInProject -ProjectPath $proj.FullName
        $map[$proj.FullName] = $files
    }

    return $map
}

function Get-ViewMapForAllViews {
    param (
        [FileSystemInfo] $FolderPath,
        [switch] $Recurse = $false
    )

    [PSCustomObject] $result = @{ }

    [FileSystemInfo[]] $views = Get-ViewFileList -Folder $FolderPath -Recurse:$Recurse

    foreach ($view in $views) {
        $result[$view.Name] = Get-ViewMapForSingleView $view
    }

    return $result
}

function Get-ViewMapForSingleView {
    param (
        [FileSystemInfo] $View
    )

    [string] $inheritsKey = [AspxDirectiveParser]::AttributeNames.Inherits
    [string] $codeFileKey = [AspxDirectiveParser]::AttributeNames.CodeFile

    $class = Get-AttributeValue $View $inheritsKey
    $codeBehind = Get-AttributeValue $View $codeFileKey

    [PSCustomObject] $result = [PSCustomObject]@{
        Path  = $View
        Class = [PSCustomObject]@{
            Name     = $class
            FileName = $codeBehind
            Path     = Get-CodeBehindPath $View $codeBehind
        }
    }
    
    return $result
}

function Get-AttributeValue {
    param (
        [FileSystemInfo] $View,
        [string] $Key
    )

    [AspxDirectiveParser] $parser = [AspxDirectiveParser]::new($View)
    [MarkupAttributeParser] $attributes = $parser.Attributes

    $result = $attributes.HasKey($Key) `
        ? [string]::IsNullOrEmpty($attributes.Value($Key)) `
        ? $null `
        : $attributes.Value($Key) `
        : $null

    return $result
}

function Get-CodeBehindPath {
    param(
        [FileSystemInfo] $View,
        [string] $CodeBehindFileName
    )

    if (Test-CodeBehindExists $View $CodeBehindFileName) {
        return Get-UntestedCodeBehindPath $View $CodeBehindFileName
    }

    return $null
}

function Test-CodeBehindExists {
    param(
        [FileSystemInfo] $View,
        [string] $CodeBehindFileName
    )

    if ([string]::IsNullOrEmpty($CodeBehindFileName)) {
        return $false
    }

    $file = Get-UntestedCodeBehindPath $View $CodeBehindFileName

    return (Test-Path -Path $file)
}

function Get-UntestedCodeBehindPath {
    param(
        [FileSystemInfo] $View,
        [string] $CodeBehindFileName
    )

    $folder = Split-Path -Path $View -Parent
    $result = Join-Path -Path $folder -ChildPath $CodeBehindFileName

    return $result
}

function Get-ViewFileList {
    param (
        [FileSystemInfo] $Folder,
        [switch] $Recurse = $false
    )

    [FileSystemInfo[]] $result = Get-ChildItem -Path $Folder -Recurse:$Recurse -Filter "*.as*x"

    return $result
}





Export-ModuleMember -Function `
    'Copy-CodeBehindWithMatchingName', `
    'Get-ClassDefinitionMap', `
    'Get-CsFilesInProject', `
    'Get-AllProjectFileMap', `
    'Get-ViewMapForAllViews', `
    'Get-ViewMapForSingleView', `
    'Get-AttributeValue', `
    'Get-CodeBehindPath', `
    'Test-CodeBehindExists', `
    'Get-UntestedCodeBehindPath', `
    'Get-ViewFileList'

