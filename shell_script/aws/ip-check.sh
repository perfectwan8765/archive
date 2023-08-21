#public ip
curl http://checkip.amazonaws.com
curl http://169.254.169.254/latest/meta-data/public-ipv4

#private ip
curl http://169.254.169.254/latest/meta-data/local-ipv4
