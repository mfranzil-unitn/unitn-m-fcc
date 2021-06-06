kubectl delete pv -n ${NAMESPACE} centodiciotto-psql-pv --grace-period=0 --force && kubectl patch pv -n ${NAMESPACE} centodiciotto-psql-pv -p '{"metadata": {"finalizers": null}}'
