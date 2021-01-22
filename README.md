# Trident Installer Addon
### the manifest

First the required namespace will be created:

#### namespace 

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
   name: trident
```

#### service user account 
In the last version the kubeconfig was required. The new version will create a service account with cluster admin rights:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: trident-installer
  namespace: trident
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: trident-installer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: trident-installer
  namespace: trident
```

#### batch job
The task to install trident is hidden an own batchjon:

```
---
apiVersion: batch/v1
kind: Job
metadata:
  name: trident-installer
  namespace: trident
spec:
  template:
    spec:
      serviceAccountName: trident-installer
      containers:
        - name: trident-installer
          image: fabianborn/trident-installer-addon:latest
          volumeMounts:
            - name: manifests
              mountPath: /manifests
            - name: backend
              mountPath: /backend
          command: ["/bin/sh"]
          args: ["/manifests/install.sh"]
      restartPolicy: OnFailure
      volumes:
        - name: manifests
          configMap:
            name: trident-installer
        - name: backend
          secret:
            secretName: trident-installer-backend

```

#### Backend and storage class configuration
for the backend configuration the install will use secret options in kubernetes. In case of multiple backends you have to create a file entry called <backend-name>.json.

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: trident-installer-backend
  namespace: trident
stringData:
  backend.json: |-
    {
      "version": 1,
      "storageDriverName": "ontap-nas",
      "backendName": "ontapnas",
      "managementLIF": "<ip-mgmt>",
      "dataLIF": "<ip-datalif>",
      "svm": "<svm-name>",
      "username": "trident_user",
      "password": "passw0rd",
      "storagePrefix": "nas"
    }
```
If you want to use more backends, you add it at the end of "stringData":
```yaml
another-backend.json: |-
    {
      configuration of backend
    }
```

Examples of backend configurations can be found in the documentation [ReadTheDocs]( https://netapp-trident.readthedocs.io/en/stable-v20.10/kubernetes/operations/tasks/backends/index.html "Netapp Trident Documentation")

All storage class information and the install script are stored as a configmap object in the kubernetes cluster again.

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: trident-installer
  namespace: trident
data:
  storage_class_trident.yaml: |-
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: trident
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
    provisioner: netapp.io/trident
    parameters:
      backendType: "ontap-nas"
    allowVolumeExpansion: True
    ---
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: trident_nas
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
    provisioner: netapp.io/trident
    parameters:
      backendType: "ontap-nas"
    allowVolumeExpansion: True
  install.sh: |-
    set -ex
    sleep 3
    kubectl apply -f /opt/trident-installer/deploy/crds/trident.netapp.io_tridentprovisioners_crd_post1.16.yaml
    kubectl apply -f /opt/trident-installer/deploy/bundle.yaml
    kubectl apply -f /opt/trident-installer/deploy/crds/tridentprovisioner_cr.yaml

    sleep 5
    i="0"
    until kubectl describe tprov trident -n trident | grep "Status:.*Installed"
    do
      sleep 10
      if [ ! $i -lt 40 ]; then
        exit 1
      fi
    done
    for backendfile in /backend/*.json; do
        /opt/trident-installer/tridentctl -n trident create backend -f /backend/$(basename $backendfile)
    done
    kubectl apply -f /manifests/storage_class_trident.yaml
    kubectl delete job.batch -n trident trident-installer


```
#### Now you can install the installer by using kubectl:
 

 
```json
backend-nas.json: |-
    {
      "version": 1,
      "storageDriverName": "ontap-nas",
      "backendName": "ontapnas",
      "managementLIF": "<ip>",
      "dataLIF": "<ip>",
      "svm": "svmname",
      "username": "trident-user",
      "password": "password",
      "storagePrefix": "nas"
    }
```


### execution:

Now you can run:

```bash
kubectl apply -f trident-installer.yaml
```

 
## Build your own Docker-Container:
```bash
docker build --build-arg TRIDENT_VERSION=20.10.1 -t <myusername>/my-trident-installer:20.10.1 .
```

Here is a short example:
[![asciicast](https://asciinema.org/a/385943.svg)](https://asciinema.org/a/385943?speed=7&autoplay=1)
