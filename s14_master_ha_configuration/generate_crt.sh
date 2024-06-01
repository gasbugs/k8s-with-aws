openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
cat cert.pem key.pem > new_cert.pem
sudo cp new_cert.pem /etc/haproxy/new_cert.pem
