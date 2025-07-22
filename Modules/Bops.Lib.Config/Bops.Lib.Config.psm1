Add-Type -TypeDefinition @"
public class NestedObject
{
    public string[] SomeStringArray { get; set; }
}

public class SomeObject
{
    public string SomeString { get; set; }
    public int SomeInt { get; set; }
    public NestedObject NestedObject { get; set; }
}

public class Config
{
    public string SymbolicLinkFolder { get; set; }
    public string InstallFolder { get; set; }
    public string Name { get; set; }
    public string Suffix { get; set; }
    public string ProfileName { get; set; }
    public SomeObject SomeObject { get; set; }
}
"@


