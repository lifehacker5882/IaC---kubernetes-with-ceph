Rook-Ceph: Installasjonsguide (HostNetwork Mode)

Dette oppsettet er spesialtilpasset for å fungere i miljøer med ustabile virtuelle nettverk (som Calico/MTU-problemer). Ved å bruke hostNetwork: true, kobler vi Ceph direkte på nodenes fysiske IP-adresser.

STEG 1: Total rens (MÅ GJØRES!)
Ceph vil nekte å starte hvis det ligger rester fra gamle installasjoner. Logg inn på alle worker-noder og slett absolutt alt i Rook-mappen:

# Kjør på worker1, worker2 og worker3
sudo rm -rf /var/lib/rook/*


STEG 2: Installasjon
# Kjør filene i denne spesifikke rekkefølgen fra control-noden:

# Grunnmur (CRDs): Definere Ceph-ressurser.
kubectl apply -f crds.yaml


# Rettigheter (Common): Sett opp RBAC og brukere.
kubectl apply -f common.yaml


# Operatøren (Operator): Start "hjernen" i systemet.
kubectl apply -f operator.yaml




Vent til operatøren er i status Running før neste steg.

# Clusteret (Cluster): Start selve lagringsnodene.
kubectl apply -f cluster.yaml


STEG 3: Verifisering
For å sjekke at alt fungerer som det skal, se etter følgende:

1. IP-adresser:
Kjør kubectl get pod -n rook-ceph -o wide. Mon-podene (a, b, c) skal ha IP-adresser i 10.196.x.x-serien (ikke pod-nettverk).

2. OSD (Disker):
Etter noen minutter skal du se rook-ceph-osd-X-poder. Dette betyr at Ceph har funnet de fysiske diskene.

3. Helse-sjekk:
Siden vi kjører på Host Network, må vi snakke med monitoren via IP for å sjekke helsen manuelt:

# Finn navnet på en mon-pod (f.eks. rook-ceph-mon-a-...)
kubectl -n rook-ceph exec <MON_POD_NAME> -- ceph status
Forventet resultat: HEALTH_OK eller HEALTH_WARN (hvis du ikke har laget pools ennå).