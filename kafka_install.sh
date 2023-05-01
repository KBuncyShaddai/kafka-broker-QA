
#NFS_IP="192.168.200.161"
#NFS_BASE_PATH="/mnt/nfs_share/dkube-104"
NFS_IP=""
NFS_BASE_PATH=""

PVs=$(cat << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv1
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-0-dkube-kafka-cp-kafka-0
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv1
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv2
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-dkube-kafka-cp-zookeeper-0
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv2
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv3
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datalogdir-dkube-kafka-cp-zookeeper-0
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv3
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv4
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-0-dkube-kafka-cp-kafka-1
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv4
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv5
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-dkube-kafka-cp-zookeeper-1
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv5
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv6
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datalogdir-dkube-kafka-cp-zookeeper-1
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv6
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv7
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-0-dkube-kafka-cp-kafka-2
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv7
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv8
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-dkube-kafka-cp-zookeeper-2
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv8
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    app: kafka-broker
  name: kafka-pv9
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datalogdir-dkube-kafka-cp-zookeeper-2
    namespace: dkube-kafka
  nfs:
    path: $NFS_BASE_PATH/kafka-broker/kafka-pv9
    server: $NFS_IP
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
EOF
)

podname=$(kubectl get po -n dkube-infra -lapp=minio  -o jsonpath={..metadata.name})
kubectl exec -it $podname -n dkube-infra -- bash -c 'rm -rf /storage/kafka-broker; i=1; while [[ $i -le 9 ]]; do mkdir -p /storage/kafka-broker/kafka-pv$i; i=$((i+1)); done; chmod -R 0777 /storage/kafka-broker'

echo "$PVs" | kubectl create -f -

helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
kubectl create ns dkube-kafka
kubectl get ns dkube-kafka
#if [[ $? -ne 0 ]]; then
#    kubectl create ns dkube-kafka
#fi
helm install dkube-kafka -f values.yaml --set cp-schema-registry.enabled=false,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false confluentinc/cp-helm-charts --namespace dkube-kafka
