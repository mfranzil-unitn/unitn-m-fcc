kubectl delete pv centodiciotto-psql-pv --grace-period=0 --force && kubectl patch pv centodiciotto-psql-pv -p '{"metadata": {"finalizers": null}}'
