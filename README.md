kjør main.yml med ansible-playook for å rulle ut ting

for å sjekke health: kubectl -n rook-ceph get cephclusters. Tar ca 8+ minutter før clusters er ferdig med setup

sjekk om disken ble montert

kubectl get pvc,pod

se om ceph jobber i bakgrunnen

kubectl exec ceph-test-pod -- df -h | grep /usr/share/nginx/html
