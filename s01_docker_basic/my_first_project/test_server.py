import socket 

with socket.socket() as s:
  s.bind(("0.0.0.0", 12345)) # 12345 포트 오픈
  s.listen()
  print("server started...")

  conn, addr = s.accept() # 클라이언트의 요청 수락
  with conn:
    print("Connected by", addr)
    while True:
      data = conn.recv(1024)
      print(f"recv data: {data.decode().strip()}")
      if 'q'==data.decode().strip(): break
      conn.sendall(data)
