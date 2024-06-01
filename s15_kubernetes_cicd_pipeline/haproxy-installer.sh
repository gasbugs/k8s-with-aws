# 도커 설치
sudo apt update
sudo apt install docker.io -y

# 도커 컴포즈 설치
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod 755 /usr/local/bin/docker-compose
docker-compose version

# 스크립트를 활용해 docker-compose로 harbor 구축하기 
wget https://gist.githubusercontent.com/kacole2/95e83ac84fec950b1a70b0853d6594dc/raw/ad6d65d66134b3f40900fa30f5a884879c5ca5f9/harbor.sh
sudo bash harbor.sh
tar -xf harbor-online-installer-v2.8.3.tgz
cd harbor/

# ca 키와 인증서 생성
mkdir pki
cd pki

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -out ca.crt \
    -keyout ca.key \
    -subj "/CN=ca"

# harbor server 키와 인증서 생성
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=harbor-server"
openssl x509 -req -in server.csr -CA ca.crt \
                                  -CAkey ca.key \
                                  -CAcreateserial -out server.crt -days 365

# 키와 인증서 복제
sudo mkdir -p /etc/docker/certs.d/server
sudo cp server.crt /etc/docker/certs.d/server/server.crt
sudo cp server.key /etc/docker/certs.d/server/server.key
sudo cp ca.crt /etc/docker/certs.d/server/ca.crt

sudo cp ca.crt /usr/local/share/ca-certificates/harbor-ca.crt
sudo cp server.crt /usr/local/share/ca-certificates/harbor-server.crt
sudo update-ca-certificates

# harbor 설정 파일 수정
cd ~/harbor/
cp harbor.yml.tmpl harbor.yml
vim harbor.yml

# 준비 스크립트는 이미지를 준비하고 인증서 파일을 위한 설정을 구성
sudo ./prepare

# install.sh 파일은 도커 컴포즈를 사용해  harbor 실행에 필요한 컨테이너들을 배포
sudo ./install.sh
​
