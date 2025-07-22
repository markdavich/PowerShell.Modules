using module User.Setup.Classes.Command

class Profile {
    $locations
    [Command[]]$commands
    $installs

    Profile($locations, [Command[]]$commands, $installs) {
        $this.locations = $locations
        $this.commands = $commands
        $this.installs = $installs
    }
}