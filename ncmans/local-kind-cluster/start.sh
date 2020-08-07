#!/bin/sh
set -xe

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8888
    protocol: TCP
EOF
kubectx kind-kind

helm repo add haproxy https://haproxytech.github.io/helm-charts
helm repo update
cat <<EOF | helm install --values=- haproxy haproxy/kubernetes-ingress
controller:
  kind: DaemonSet
  service:
    type: ClusterIP
  daemonset:
    useHostPort: true
  replicaCount: 1
  nodeSelector:
    ingress-ready: "true"
  tolerations:
  - key: node-role.kubernetes.io/master
    operator: Equal
    effect: NoSchedule
defaultBackend:
  replicaCount: 0
EOF
cat <<EOF | kubectl apply -f-
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - http:
      paths:
      - path: /web
        backend:
          serviceName: web
          servicePort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: bash
        args:
        - -c
        - "while true; do echo $'HTTP/1.0 200 OK\r\n\r\nHi there :)' | nc -l -p 80; done"
        image: bash
        ports:
        - containerPort: 80
EOF

cat <<EOF


curl http://localhost:8888/web



EOF
