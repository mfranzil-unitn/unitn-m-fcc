kubectl delete pv -n centodiciotto-dev centodiciotto-psql-pv --grace-period=0 --force && kubectl patch pv -n centodiciotto-dev centodiciotto-psql-pv -p '{"metadata": {"finalizers": null}}'
