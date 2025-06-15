# Setting up K3s monitoring with external Prometheus

For external monitoring we are using the existing [Docker-compose](../../../monitoring/monitoring_compose.yml) for service monitoring and updating it necessarily. Now if you are running k3s on tailscale nodes you will need to add another Tailscale sidecar container for accessing metrics from those nodes.

The Docker compose must be updated with a Tailscale OAuth client token for the sidecar to authenticate into your Tailnet.

Read this article for a detailed setup instruction: https://medium.com/@kunalvirwal/how-i-set-up-secure-external-monitoring-for-my-k3s-cluster-with-prometheus-and-tailscale-eba972dc19eb

Also for k3s to export metrics we need to run k3s with some configs and modify the `/etc/rancher/k3s/config.yaml` with [config.yaml](../../config.yaml).

Then for providing access of the cluster we need to create a new service account and assign it a cluster role that allows it read access to resources in the cluster. For accessing the cluster we would need a CA certificate and a Service Account token, which can be extracted using the steps mentioned in the above article. This CA-cert and Kube-SA-token should be kept in the same directory as `prometheus.yaml`.

Create the relevant resources.

```
kubectl apply -f namespace-and-sa.yaml
kubectl apply -f prometheus-cluster-role.yaml
kubectl apply -f prometheus-cluster-role-binding.yaml
kubectl apply -f sa-secret.yaml
```

Extracting kube-sa-token

```
kubectl -n monitoring get secret prom-ext-api-user-token -o jsonpath=’{.data.token}’ | base64 -d > kube-sa-token
```

Extracting CA certificate

```
kubectl -n monitoring get secret prom-ext-api-user-token -o jsonpath=’{.data.ca\.crt}’ | base64 -d > ca.crt
```

These two files have to be mounted with prometheus.yaml in `/etc/prometheus` inside the container and [prometheus.yml](../../../monitoring/prometheus.yml) should be updated to gather metrics from a K3s cluster.



