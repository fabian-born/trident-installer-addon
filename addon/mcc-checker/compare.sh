    /opt/trident-installer/tridentctl -n trident get backend -o json > /tmp/current.json
    kubectl get configmap -n trident tbe-data -o jsonpath='{.data.tbe-data-current\.json}' > /tmp/new-last.json
    kubectl get configmap -n trident tbe-data -o jsonpath='{.data.tbe-data-last\.json}' > /tmp/last.json
   
    if (cmp -s /tmp/current.json /tmp/new-last.json)
    then
      echo "No Config change"
    else
      echo "The files are different"
     
      kubectl create configmap -n trident tbe-data --from-file=tbe-data-current.json=/tmp/current.json --from-file=tbe-data-last.json=/tmp/new-last.json --dry-run -o yaml | k apply -f - 
    fi

