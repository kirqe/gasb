# gasb api

Web part and api of gasb.app

```
GET # /api/status/month:11111111:sessions

# => { "term":"month:11111111:sessions","value":48,"updated_at":"2020-11-23 02:34:55 +0300", queued: false }
```

#### Notes and links

```
helm/cert.yaml
helm/global.yaml
helm/ingress.yaml

helm install -f ingress.yaml ingress ingress/
```

- [cert-manager](https://cert-manager.io/docs/installation/kubernetes/)

