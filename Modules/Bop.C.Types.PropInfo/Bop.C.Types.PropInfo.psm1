using namespace System.Reflection

class PropInfo {
    [string] $PropertyName
    [bool] $HasProperty
    [object] $Value
    [object] $Parent
    [PropertyInfo] $PropertyInfo
    [bool] $CanWrite

    PropInfo([object] $Object, [string] $PropertyName) {
        $this.Parent = $Object
        $this.PropertyName = $PropertyName
        
        $this.PropertyInfo = [PropInfo]::GetPropertyInfo(
            $Object, 
            $PropertyName
        )

        $this.HasProperty = $null -ne $this.PropertyInfo

        if ($this.HasProperty) {
            $this.CanWrite = $this.PropertyInfo.CanWrite
        }

        $this.Value = [PropInfo]::GetValue(
            $Object,
            $PropertyName
        )
    }
    
    static [object] GetValue([object] $Object, [string] $PropertyName) {
        [PropertyInfo] $info = [PropInfo]::GetPropertyInfo(
            $Object, 
            $PropertyName
        )
            
        if ($null -eq $info) {
            return $null
        }
            
        $result = $info.GetValue($Object, $null)
            
        return $result
    }
        
    static [PropertyInfo] GetPropertyInfo([object] $Object, [string] $PropertyName) {
        $result = $Object.GetType().GetProperty(
            $PropertyName,
            [System.Reflection.BindingFlags]::IgnoreCase -bor
            [System.Reflection.BindingFlags]::Public -bor
            [System.Reflection.BindingFlags]::Instance
        )
        
        return $result
    }
} 