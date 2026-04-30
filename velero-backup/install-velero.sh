#!/bin/bash
kubectl apply -f minio-setup.yaml

echo "Venter på MinIO..."
kubectl wait --for=condition=available --timeout=600s deployment/minio -n velero

# LEGG TIL DISSE TO LINJENE:
echo "Venter 30 sekunder på at DNS skal oppdatere seg..."
sleep 30

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.9.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --use-node-agent \
    --use-volume-snapshots=false \
    --namespace velero \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.velero.svc:9000

echo "Velero er installert. Sjekk status med: velero backup-location get"
