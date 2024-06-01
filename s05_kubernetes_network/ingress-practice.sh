# 연습 문제
# 다음 요구사항을 모두 만족하는 인그레스와 서비스, 디플로이먼트를 생성하라.
# tomcat.gasbugs.com 도메인으로 consol/tomcat-7.0 서비스를 지원
# http-go.gasbugs.com 도메인으로 gasbugs/http-go 서비스를 지원
# 모든 서비스는 SSL 통신을 지원
# HTTP 포트로 접근 시 HTTPS로 리다이렉션하도록 구성

kubectl delete all --all

# http-go 디플로이먼트/서비스 생성
kubectl create deploy http-go --image=gasbugs/http-go 
kubectl expose deploy http-go --port=80 --target-port=8080

# 톰캣 디플로이먼트/서비스 생성
kubectl create deploy tomcat --image=consol/tomcat-7.0 
kubectl expose deploy tomcat --port=80 --target-port=8080

# TLS 인증서 생성
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out gasbugs-tls.crt \
    -keyout gasbugs-tls.key \
    -subj "/CN=ingress-tls"

# tls 인증서를 통해 secret을 구성
kubectl create secret tls gasbugs-tls \
    --namespace default \
    --key gasbugs-tls.key \
    --cert gasbugs-tls.crt

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: http-go-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - tomcat.gasbugs.com    
    - http-go.gasbugs.com
    secretName: gasbugs-tls
  rules:
    - host: http-go.gasbugs.com
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: http-go
                port: 
                  number: 80
    - host: tomcat.gasbugs.com
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: tomcat
                port: 
                  number: 80
EOF