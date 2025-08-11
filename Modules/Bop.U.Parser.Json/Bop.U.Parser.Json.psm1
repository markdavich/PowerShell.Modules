using module Bop.U.Json
using module Bop.U.Types
using module Bop.C.Types.PropInfo

class JsonParser {
    hidden [hashtable] $_json
    hidden [Type] $_type
    [object] $_instance

    JsonParser([string] $Path, [Type] $Type) {
        $this._json = Get-Json -Path $Path # Get-Json returns a Hashtable
        $this._type = $Type
        $this._instance = [System.Activator]::CreateInstance($Type)
        $this.Parse($this._json, $this._instance)
    }

    hidden [void] Parse([object] $Source, [object] $Destination) {
        if ($null -eq $Source -or $null -eq $Destination) {
            return
        }

        if ($Source -is [System.Collections.IDictionary]) {
            # Iterate hashtable keys (JSON object)
            foreach ($key in $Source.Keys) {
                $value = $Source[$key]

                # Get the matching property from the destination type
                # $prop = $Destination.GetType().GetProperty($key)

                $prop = [PropInfo]::GetPropertyInfo($Destination, $key)

                if ($null -eq $prop -or -not $prop.CanWrite) { continue }

                # Get the expected destination type
                $targetType = $prop.PropertyType

                if ($value -is [System.Collections.IDictionary]) {
                    # Recursively build nested object
                    $nested = [Activator]::CreateInstance($targetType)
                    $this.Parse($value, $nested)
                    $prop.SetValue($Destination, $nested)
                }
                elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
                    # Handle arrays/lists
                    $elementType = $null

                    if ($targetType.IsArray) {
                        $elementType = $targetType.GetElementType()
                    }
                    elseif ($targetType.IsGenericType) {
                        $elementType = $targetType.GetGenericArguments()[0]
                    }

                    if ($elementType) {
                        $list = [System.Collections.ArrayList]::new()

                        foreach ($item in $value) {
                            if ($item -is [System.Collections.IDictionary]) {
                                $elementInstance = [Activator]::CreateInstance($elementType)
                                $this.Parse($item, $elementInstance)
                                $list.Add($elementInstance) | Out-Null
                            }
                            else {
                                $list.Add([Convert]::ChangeType($item, $elementType)) | Out-Null
                            }
                        }

                        # Convert list to correct type
                        if ($targetType.IsArray) {
                            $typedArray = $list.ToArray($elementType)
                            $prop.SetValue($Destination, $typedArray)
                        }
                        else {
                            $typedList = [Activator]::CreateInstance($targetType)
                            foreach ($entry in $list) {
                                $typedList.Add($entry)
                            }
                            $prop.SetValue($Destination, $typedList)
                        }
                    }
                }
                else {
                    # Primitive or directly assignable value
                    $converted = [Convert]::ChangeType($value, $targetType)
                    $prop.SetValue($Destination, $converted)
                }
            }
        }
    }

    [object] GetInstance() {
        $result = Convert-ToType -Value $this._instance -Type $this._type
        return $result
    }
}