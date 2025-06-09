# Setting up K3s monitoring using kube-prometheus-stack

To set up monitoring for a K3s cluster, we can use `kube-prometheus-stack`, also known as `prometheus-operator`. This operator sets up all the resources needed to run an internal monitoring suite inside the cluster itself. The easiest way to set it is using a `Helm Chart`. Helm Charts are a collection of configuration files used to set up workloads and applications on Kubernetes based clusters.

Official documentation of `kube-prometheus-stack` can be found on https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

## Installing kube-prometheus-stack

Firstly, we need to add the Helm repository for prometheus-operator.

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Next, install the particular helm chart for `kube-prometheus-stack` on our cluster. Make sure the cluster is accessible and the kube config is already set. In the following command, the chart will be installed with the release name `monitoring`.  

```
helm install monitoring prometheus-community/kube-prometheus-stack
```

Now, if you are using `k3s`, `minikube`, or any other variation of Kubernetes, you will get cluster-specific instructions to temporarily expose your Grafana dashboard and access it from your browser.

When you install this helm chart, it installs many resources, which you can see using `kubectl get all`. All these resources are from the chart `kube-prometheus` with release name `monitoring`, both of which will regularly appear in the names of these resources.

## Resources Created

### StatefulSets

It firstly starts 2 `statefulsets`.
```
NAME                                                                    READY   AGE
statefulset.apps/alertmanager-monitoring-kube-prometheus-alertmanager   1/1     12m
statefulset.apps/prometheus-monitoring-kube-prometheus-prometheus       1/1     12m
```

The second one is the actual Prometheus server, and the first one is the alertmanager, and both of these will be managed by the operator, as its name is there in their pod name.

### Deployments and ReplicaSets

Then we have 3 `deployments`.
```
NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/monitoring-grafana                    1/1     1            1           12m
deployment.apps/monitoring-kube-prometheus-operator   1/1     1            1           12m
deployment.apps/monitoring-kube-state-metrics         1/1     1            1           12m
```

The second deployment is the operator itself that created the statefulsets.
The first one is the Grafana deployment.
The last one is `kube-state-metrics`, which is basically itself a Helm chart and is a dependency of this chart.  

It scrapes Kubernetes' component metrics itself, like deployments, statefulsets, pods, and makes them available inside the cluster for Prometheus to pull.

We also have 3 replicasets regarding the 3 deployments that we created.
```
NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/monitoring-grafana-659dc94559                    1         1         1       12m
replicaset.apps/monitoring-kube-prometheus-operator-7985c9d66b   1         1         1       12m
replicaset.apps/monitoring-kube-state-metrics-59fb8cc694         1         1         1       12m 
```

### DaemonSet

Then we have a `daemonset`. This corresponds to `node-exporter`. The property of daemonsets is that they run on all the nodes of the cluster and thus help us to extract node metrics from all the nodes.
```
NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/monitoring-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   12m
```

### Pods

The 6 pods correspond to the deployments.
```
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   0          12m
pod/monitoring-grafana-659dc94559-j5d2f                      3/3     Running   0          12m
pod/monitoring-kube-prometheus-operator-7985c9d66b-mf8bp     1/1     Running   0          12m
pod/monitoring-kube-state-metrics-59fb8cc694-w6v9k           1/1     Running   0          12m
pod/monitoring-prometheus-node-exporter-8t8fh                1/1     Running   0          12m
pod/prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   0          12m
```

### Services

And at last we have services corresponding to those 6 pods, 1 daemonset, and 2 statefulsets
```
NAME                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   12m
service/kubernetes                                ClusterIP   10.43.0.1       <none>        443/TCP                      31h
service/monitoring-grafana                        ClusterIP   10.43.202.70    <none>        80/TCP                       12m
service/monitoring-kube-prometheus-alertmanager   ClusterIP   10.43.117.121   <none>        9093/TCP,8080/TCP            12m
service/monitoring-kube-prometheus-operator       ClusterIP   10.43.139.140   <none>        443/TCP                      12m
service/monitoring-kube-prometheus-prometheus     ClusterIP   10.43.79.150    <none>        9090/TCP,8080/TCP            12m
service/monitoring-kube-state-metrics             ClusterIP   10.43.173.77    <none>        8080/TCP                     12m
service/monitoring-prometheus-node-exporter       ClusterIP   10.43.141.116   <none>        9100/TCP                     12m
service/prometheus-operated                       ClusterIP   None            <none>        9090/TCP                     12m
```

Other than these, there will be a lot of configmaps and secrets that define how things work and are monitored.

## Locating Prometheus configurations

If we describe the Prometheus statefulset and store the output in a file. We can see all the containers that are running inside its pods. In the container definition of the main Prometheus container, we can see the mount point definitions where we will find the Prometheus config file and the alerting rules file.  

The second container in this pod is the reloader that tells Prometheus to reload when the configuration changes. Default config files are created as configmaps and secrets.

Against the mount points, pod volumes are mentioned that contain the configuration files. Further in the configuration if we can see that the volume will point to a configmap or a secret.

```
...

Mounts:
 /etc/prometheus/config from config (rw)

...

Volumes:
  config:
   Type:        Secret (a volume populated by a Secret)
   SecretName:  prometheus-monitoring-kube-prometheus-prometheus
   Optional:    false
```

Here, `prometheus-monitoring-kube-prometheus-prometheus` is the secret that stores the Prometheus config file.

## Exposing Grafana service

Upon running `kubectl get svc`, we see that all the services are of cluster IP type, which are not accessible outside the cluster. In prod, we can define an ingress to access the Grafana service, but here we can just port forward.

We need to get the deployment and container name to set up port forwarding. We can find these to be `monitoring-grafana` and `monitoring-grafana-659dc94559-j5d2f` respectively, and we can see the logs of this pod to see that Grafana is accessible on port 3000 of the container.
The default user is `admin` and the default password is `prom-operator`.

Now we can forward port 3000 of the pod to port 3031 of the worker node using the following command on the node and accessing port 3031 of the cluster node IP:

```
kubectl port-forward deployment/monitoring-grafana --address 0.0.0.0 3031:3000
```
