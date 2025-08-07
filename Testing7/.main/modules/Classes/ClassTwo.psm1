using namespace System.IO

using module .\ClassOne.psm1

class ClassTwo {
    [FileSystemInfo] hidden $_path
    [string] hidden $_name
    [bool] hidden $_isReady

    ClassTwo([ClassOne]$ClassOne) {
        $this._path = $ClassOne.Path
        $this._name = $ClassOne.Name
        $this._isReady = $ClassOne.IsReady
    }

    [FileSystemInfo] get_Path() {
        return $this._path
    }

    [string] get_Name() {
        return $this._Name
    }

    [bool] get_IsReady() {
        return $this._isReady
    }
}


