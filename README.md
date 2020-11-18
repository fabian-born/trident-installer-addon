# New Trident Installer
### Docker Image to setup NetApp Trident in a Kubernetes Cluster

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/fabianborn/k8s-trident-installer)


#### Now you can install the installer by using kubectl:

This yaml-file deploys the NetApp Trident storage provisioner to a kubernetes cluster. Before you apply the configuration the backend.json must be defined:

```
backend.json: |-
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

##### execution:

``` 
kubectl apply -f trident-installer.yaml
```



Here is a short example:
[![asciicast](https://asciinema.org/a/gKTMvKguMYOINNOtcNxSiZCKR.svg)](https://asciinema.org/a/)