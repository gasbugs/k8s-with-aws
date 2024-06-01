cat <<EOF > daemon.json
{
    "insecure-registries": ["docker.com", "hub.docker.com", "18.209.59.9"]
}
EOF

sudo cp daemon.json /etc/docker/daemon.json