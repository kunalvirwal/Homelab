
## Modules
- The `apt` module is useful for updating linux packages.
- the `template` package helps transfer jinja2 based files with variable enclosed in `{{}}`.
- The `artis3n-tailscale` role is necessary to run the tailscale setup ansible. 

## To ping any/all servers

Can replace linux by group name or all or any hostname present in ./inventory/hosts
This command should be ran assuming the host or group of host has SSH key based authentication.  
If using password for authentication then use the `--ask-pass` flag. To use password based authentication, the sshpass package must be installed on the master node before running the command.

```
$ ansible -i ./hosts linux -m ping --user $ServerAdminAccount
```

## To run any playbook

If a playbook requires sudo permissions to run then use the `--ask-become-pass` flag to prompt for the sudo password otherwise can also provider it in the host file.
If key based auth is not set up then use both `--ask-pass` followed by `--ask-become-pass` simultaneously.

```
$ ansible-playbook ./path/to/playbook --user $ServerAdminAccount --ask-become-pass -i ./hosts  
```
