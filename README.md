#kjør main.yml med ansible-playook for å rulle ut ting

#for å sjekke health: 
kubectl -n rook-ceph get cephclusters. Tar ca 8+ minutter før clusters er ferdig med setup

#sjekk om disken ble montert
kubectl get pvc,pod

#se om ceph jobber i bakgrunnen
kubectl exec ceph-test-pod -- df -h | grep /usr/share/nginx/html

# Hent token med din brukerinfo
TOKEN=$(curl -s --user 'BRUKERNAVN:PASSORD' "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)

# Sjekk status
curl -i -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1 | grep -i ratelimit

# finn garafan pod bruk
grafana-pod-vm-ip:32000 (fra nodePort deklarert)

#legg til source med prometheus url
http://prometheus-server.monitoring.svc.cluster.local

# dashboard id
# node exporter
1860

# når velero er installert for å sjekke om velero kjører
kubectl -n velero exec deploy/velero -- /velero version
kubectl -n velero exec deploy/velero -- /velero backup-location get
kubectl -n velero exec deploy/velero -- /velero backup get

# verifiser Backupstoragelocation før smoke test
kubectl get backupstoragelocation -n velero
kubectl describe backupstoragelocation default -n velero
kubectl -n velero logs deploy/velero --tail=200

# kjør smoke testen hvis alt gikk gjennom
kubectl create ns velero-smoke
kubectl -n velero-smoke create configmap smoke-cm --from-literal=ok=yes

kubectl -n velero exec deploy/velero -- /velero backup create smoke-backup-2 --include-namespaces velero-smoke --wait
kubectl -n velero exec deploy/velero -- /velero backup describe smoke-backup-2 --details
kubectl -n velero exec deploy/velero -- /velero backup logs smoke-backup-2

# slett smoke testen
kubectl delete ns velero-smoke --wait=true
kubectl -n velero exec deploy/velero -- /velero restore create --from-backup smoke-backup-2 --wait
kubectl get ns velero-smoke
kubectl -n velero-smoke get configmap smoke-cm
