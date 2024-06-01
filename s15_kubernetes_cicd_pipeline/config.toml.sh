# 쿠버네티스를 위한 Containerd 설정
sudo rm /etc/containerd/config.toml
cat <<EOF | sudo tee -a /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
[plugins.cri.registry.configs."18.209.59.9".tls]
  insecure_skip_verify = true
EOF

# 서비스 재시작
sudo service containerd restart
sudo service kubelet restart
sudo service containerd status
sudo service kubelet status