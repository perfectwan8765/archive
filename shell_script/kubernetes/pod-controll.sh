# delete pod status Error (ex. namespace airflow)
kubectl get pod -o wide -n airflow | awk '$3 == "Error" {print $1 " -n airflow"}' | xargs kubectl delete pod
