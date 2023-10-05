# ser2net docker-container

Docker container for [ser2net](https://github.com/cminyard/ser2net).

e.g.: `ghcr.io/elmarx/ser2net:4`

builds daily the latest ser2net tag. 

[See all available tags](https://github.com/elmarx/ser2net/pkgs/container/ser2net).

## Example

Given a file `ser2net.yaml`:

```yaml
connection: &con01
  accepter: tcp,20108
  connector: serialdev,/dev/ttyACM0,115200n81,local
  options:
    kickolduser: true
```

Mount it to ``/etc/ser2net/ser2net.yaml`, mount `/dev/ttyACM0`, and add the privileged flag.

## Kubernetes

I run this in kubernetes. This is the essence of my deployment:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ser2net
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  selector:
    matchLabels:
      app: ser2net
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: ser2net
    spec:
      containers:
        - image: ghcr.io/elmarx/ser2net:4.5.0
          imagePullPolicy: Always
          name: ser2net
          ports:
            - containerPort: 20108
          resources: {}
          securityContext:
            privileged: true
          volumeMounts:
            - mountPath: /etc/ser2net/ser2net.yaml
              mountPropagation: None
              name: config
              subPath: ser2net.yaml
            - mountPath: /dev/ttyACM0
              mountPropagation: None
              name: device
      nodeSelector:
        kubernetes.io/hostname: host-where-the-device-is-available
      volumes:
        - configMap:
            name: ser2net
          name: config
        - hostPath:
            path: /dev/ttyACM0
          name: device
---
apiVersion: v1
kind: Service
metadata:
  name: ser2net
spec:
  selector:
    app: ser2net
  ports:
    - protocol: TCP
      port: 20108
      targetPort: 20108
  type: NodePort
---
apiVersion: v1
data:
  ser2net.yaml: |
    connection: &con01
      accepter: tcp,20108
      connector: serialdev,/dev/ttyACM0,115200n81,local
      options:
        kickolduser: true
kind: ConfigMap
metadata:
  name: ser2net
```


