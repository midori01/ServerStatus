# Download
wget --no-check-certificate -qO status.sh 'https://raw.githubusercontent.com/midori01/serverstatus/master/status.sh'

# Install Server
bash status.sh -i -s

# Install Client
bash status.sh -i -c http://TEST1:password@127.0.0.1:9393

# More
❯ bash status.sh
