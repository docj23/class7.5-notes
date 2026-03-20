#!/bin/bash

#  Grab the Metadata 
VM_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)

# Create the html file
cat <<EOF > index.html
<html>
<body>
  <h1>VM Metadata:</h1>
  <p><b>Project</b>: $PROJECT_ID</p>
  <p><b>VM Name</b>: $VM_NAME</p>
  <p><b>Internal IP</b>: $INTERNAL_IP</p>
</body>
</html>
EOF

# Start the server
nohup python3 -m http.server 80 --bind 0.0.0.0  > /var/log/python_server.log 2>&1 &
