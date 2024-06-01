# 관리자 권한
sudo -i

# docker 설치
yum update -y && yum install -y docker
systemctl enable docker --now

# 도커를 사용해 jenkins 구성 및 도커 소켓 공유
docker run -d -p 80:8080 --name jenkins -v /home/jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -u root jenkins/jenkins:lts

# 도커 설정 파일에서 신뢰할 수 있는 레지스트리로 추가
cat <<EOF > daemon.json
{
    "insecure-registries": ["docker.com", "hub.docker.com", "<Harbor IP>"]
}
EOF

sudo cp daemon.json /etc/docker/daemon.json
sudo service docker restart

# 잘 동작하는지 테스트 
sudo docker login <HarborIP> 

# jenkins 컨테이너 시작하고 로그에서 패스워드 확인 
sudo docker start jenkins
sudo docker logs jenkins