# delete pod status Error (ex. namespace airflow)
kubectl get pod -o wide -n airflow | awk '$3 == "Error" {print $1 " -n airflow"}' | xargs kubectl delete pod

# get pod list using pvc
kubectl get pods --all-namespaces -o=json | jq -c '.items[] | {name: .metadata.name, namespace: .metadata.namespace, claimName: .spec |  select( has ("volumes") ).volumes[] | select( has ("persistentVolumeClaim") ).persistentVolumeClaim.claimName }'

# pod status complete
kubectl get pods --field-selector=status.phase=Succeeded -n cvat

# pod status containerunknown, error
kubectl get pods --field-selector=status.phase=Failed -n cvat

# old revision replicaset delete
kubectl delete replicaset $(kubectl get replicaset -o jsonpath='{ .items[?(@.spec.replicas=0)].metadata.name }' -n jupyterhub) -n jupyterhub

# get pvc of pods
kubectl get pods --all-namespaces -o=json | jq -c '.items[] | {name: .metadata.name, namespace: .metadata.namespace, claimName: .spec |  select( has ("volumes") ).volumes[] | select( has ("persistentVolumeClaim") ).persistentVolumeClaim.claimName }'
