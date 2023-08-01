#!/bin/bash
if [ -n "$1" ]; then
  echo Cluster name: $1.
else
  echo "No cluster name has been specified. "
  exit 1
fi
kubectl create serviceaccount --namespace kube-system superuser
kubectl create clusterrolebinding superuser-rule --clusterrole=cluster-admin --serviceaccount=kube-system:superuser

A=$(kubectl -n kube-system describe secret/$(kubectl -n kube-system get sa/superuser -o jsonpath='{.secrets[0].name}')|awk '{for(i=1;i<=NF;i++)if($i=="token:")print $(i+1)}')
B=$(kubectl config view --flatten --minify|awk '{for(i=1;i<=NF;i++)if($i=="certificate-authority-data:")print $(i+1)}')
C=$(kubectl config view --flatten --minify|awk '{for(i=1;i<=NF;i++)if($i=="server:")print $(i+1)}')
D=$(kubectl config view --flatten --minify|awk '{for(i=1;i<=NF;i++)if($i=="name:")print $(i+1)}'|head -1)

cat <<EOF >kubeconfig.$1
apiVersion: v1
kind: Config
users:
- name: superuser
  user:
    token: $A
clusters:
- cluster:
    certificate-authority-data: $B
    server: $C
  name: $D
contexts:
- context:
    cluster: $D
    user: superuser
  name: $D-context
current-context: $D-context
EOF
