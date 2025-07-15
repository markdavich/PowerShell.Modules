class Command {
    [string]$name
    [string]$alias
    [string]$description
    [string[]]$params
    [string]$icon

    Command([string]$name, [string]$alias, [string]$description, [string[]]$params, [string]$icon) {
        $this.name = $name
        $this.alias = $alias
        $this.description = $description
        $this.params = $params
        $this.icon = $icon
    }
}