using namespace System.IO

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


Export-ModuleMember -Function `
    Copy-CodeBehindWithMatchingName `
    Get-ClassDefinitionMap `
    Get-CsFilesInProject `
    Get-AllProjectFileMap