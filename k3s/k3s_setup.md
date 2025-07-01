# K3s Setup

Note: It is recommended to use the config.yaml files provided to set startup instructions for K3s instead of using inline flags. 

## Setting up first node (k3s-server and k3s-agent)

- `--tls-san` flag adds the provided IPs and DNS names into the tls certificate that is
 used in https requests made kubectl. This can be a master or a LB to the masters.  

- `--cluster-init` flag tells the cluster to start with an etcd instance instead of an external database.  

- This command by default starts both a `k3s-server` and a `k3s-agent`. You can use any string here for the token.  

```
curl -sfL https://get.k3s.io | sh -s - server \
 --token=<token> \
 --tls-san <master-DNS-name> --tls-san <master-Node-IP> \
 --cluster-init
```

## Setting up k3s-agent without k3s-server

- To install an agent on a separate node run a similar command without `- server`
in the install script or `--tls-sans` flag or the `--cluster-init` flag and using
the `--server` flag to define the master API.  

- NOTE: If you did run with `--tls-san` and `- server` then the node will have a
`master` setup also with its own `etcd` and `agent`. This way the cluster will become Highly Available (HA) but then you need to use a LB between the masters and use that IP in `--tls-san`.  

- NOTE: High Availability can only be achived when more than half of the instances of `etcd` are up. Thus atleast 3 nodes are required to have a HA and it will work as long as 2 nodes are up.

```
curl -sfL https://get.k3s.io | sh -s - agent\
 --token=<token> \
 --server https://master-Node-IP:6443
```

- You can check status of k3s using  `systemctl status k3s`.  

- Logs of k3s can be seen using `journelctl -t k3s`.  

## Setting up kubectl

- To use `kubectl` on you host machine outside the cluster, copy the contents of
`/etc/rancher/k3s/k3s.yaml` into your device's `~/.kube/config` and modify the server
field in cluster object to the IP of your master or registered LB between the masters.  

- You can also change the name field in cluster object from default to any thing else,
if you do this then replace it wherever you find it in the file.

- Now on your machine you can list all configs wrt to each cluster you have configured.

```
kubectl config get-contexts
```

- You can switch the `kubectl` context to this cluster by running the following command.
```
kubectl config use <cluster-name-you-set>
```

- Now kubectl commands will work from this device as long as the IP:6443 added in `~/.kube/config` is accessible.