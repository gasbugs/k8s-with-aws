openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out ingress-tls.crt \
    -keyout ingress-tls.key \
    -subj "/CN=ingress-tls"

kubectl create secret tls ingress-tls \
    --namespace default \
    --key ingress-tls.key \
    --cert ingress-tls.crt