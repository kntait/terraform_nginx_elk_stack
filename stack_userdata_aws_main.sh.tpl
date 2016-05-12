#!/bin/bash -ex
LOG_FILE=/var/log/cloudinit/pre_env_cloud_init.out
mkdir -p `dirname "$LOG_FILE"`
touch "$LOG_FILE"
chmod 600 "$LOG_FILE"
{
date
echo "Running cloud init for stack"

##################
#  General Setup # 
##################

echo 'Setting custom hostname'
hostname ${instance_name}

echo 127.0.0.1 ${instance_name} >> /etc/hosts
sed -i "20 s/^/#/" /etc/cloud/cloud.cfg
sed -i "21 s/^/#/" /etc/cloud/cloud.cfg
sed -i '1s/.*/${instance_name}/' /etc/hostname

##################
# Yum repo setup #
##################

cat << EOF > /etc/pki/rpm-gpg/DOCKER-GPG-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQINBFWln24BEADrBl5p99uKh8+rpvqJ48u4eTtjeXAWbslJotmC/CakbNSqOb9o
ddfzRvGVeJVERt/Q/mlvEqgnyTQy+e6oEYN2Y2kqXceUhXagThnqCoxcEJ3+KM4R
mYdoe/BJ/J/6rHOjq7Omk24z2qB3RU1uAv57iY5VGw5p45uZB4C4pNNsBJXoCvPn
TGAs/7IrekFZDDgVraPx/hdiwopQ8NltSfZCyu/jPpWFK28TR8yfVlzYFwibj5WK
dHM7ZTqlA1tHIG+agyPf3Rae0jPMsHR6q+arXVwMccyOi+ULU0z8mHUJ3iEMIrpT
X+80KaN/ZjibfsBOCjcfiJSB/acn4nxQQgNZigna32velafhQivsNREFeJpzENiG
HOoyC6qVeOgKrRiKxzymj0FIMLru/iFF5pSWcBQB7PYlt8J0G80lAcPr6VCiN+4c
NKv03SdvA69dCOj79PuO9IIvQsJXsSq96HB+TeEmmL+xSdpGtGdCJHHM1fDeCqkZ
hT+RtBGQL2SEdWjxbF43oQopocT8cHvyX6Zaltn0svoGs+wX3Z/H6/8P5anog43U
65c0A+64Jj00rNDr8j31izhtQMRo892kGeQAaaxg4Pz6HnS7hRC+cOMHUU4HA7iM
zHrouAdYeTZeZEQOA7SxtCME9ZnGwe2grxPXh/U/80WJGkzLFNcTKdv+rwARAQAB
tDdEb2NrZXIgUmVsZWFzZSBUb29sIChyZWxlYXNlZG9ja2VyKSA8ZG9ja2VyQGRv
Y2tlci5jb20+iQI4BBMBAgAiBQJVpZ9uAhsvBgsJCAcDAgYVCAIJCgsEFgIDAQIe
AQIXgAAKCRD3YiFXLFJgnbRfEAC9Uai7Rv20QIDlDogRzd+Vebg4ahyoUdj0CH+n
Ak40RIoq6G26u1e+sdgjpCa8jF6vrx+smpgd1HeJdmpahUX0XN3X9f9qU9oj9A4I
1WDalRWJh+tP5WNv2ySy6AwcP9QnjuBMRTnTK27pk1sEMg9oJHK5p+ts8hlSC4Sl
uyMKH5NMVy9c+A9yqq9NF6M6d6/ehKfBFFLG9BX+XLBATvf1ZemGVHQusCQebTGv
0C0V9yqtdPdRWVIEhHxyNHATaVYOafTj/EF0lDxLl6zDT6trRV5n9F1VCEh4Aal8
L5MxVPcIZVO7NHT2EkQgn8CvWjV3oKl2GopZF8V4XdJRl90U/WDv/6cmfI08GkzD
YBHhS8ULWRFwGKobsSTyIvnbk4NtKdnTGyTJCQ8+6i52s+C54PiNgfj2ieNn6oOR
7d+bNCcG1CdOYY+ZXVOcsjl73UYvtJrO0Rl/NpYERkZ5d/tzw4jZ6FCXgggA/Zxc
jk6Y1ZvIm8Mt8wLRFH9Nww+FVsCtaCXJLP8DlJLASMD9rl5QS9Ku3u7ZNrr5HWXP
HXITX660jglyshch6CWeiUATqjIAzkEQom/kEnOrvJAtkypRJ59vYQOedZ1sFVEL
MXg2UCkD/FwojfnVtjzYaTCeGwFQeqzHmM241iuOmBYPeyTY5veF49aBJA1gEJOQ
TvBR8Q==
=Fm3p
-----END PGP PUBLIC KEY BLOCK-----
EOF

cat << EOF > /etc/yum.repos.d/docker.repo
[docker]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/DOCKER-GPG-KEY
EOF

#yum -y update

#############################
#  Directory and file Setup # 
#############################

mkdir /opt/app
mkdir /opt/app/logstash
mkdir /opt/app/nginx
touch /opt/app/nginx/test_site_access.log

cat << EOF > /opt/app/logstash/logstash.conf
input {
  file {
      path => "/var/log/nginx/test_site_access.log"
  }
}
## Add your filters here
output {
  elasticsearch {
    hosts => "elasticsearch:9200"
  }
}
EOF

cat << EOF > /opt/app/nginx/htpasswd
admin:\$$apr1\$$e6LaMI2c\$$LIiwzpQyFAGtZ4dZdmuwv0
EOF

cat << EOF > /opt/app/nginx/nginx.conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;

pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
  access_log /var/log/nginx/test_site_access.log;
    
  # Proxy to Kibana and prompt for credentials
  server {
      listen 8080;
      server_name elk;
      location / {
          # You can set password protection
          auth_basic "Restricted";
          auth_basic_user_file /etc/nginx/htpasswd;
          proxy_pass  http://kibana:5601/;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
          proxy_set_header        Host             \$$host;
          proxy_set_header        X-Real-IP        \$$remote_addr;
          proxy_set_header        X-Forwarded-For  \$$proxy_add_x_forwarded_for;
      }
  }
  # Serve content from s3
  server {
    listen 80;
    server_name static.s3; # Edit your domain and subdomain
   
    location / {
      proxy_set_header       Host '${aws_s3_bucket_region}';
      proxy_set_header       Authorization '';
      proxy_hide_header      x-amz-id-2;
      proxy_hide_header      x-amz-request-id;
      proxy_hide_header      Set-Cookie;
      proxy_ignore_headers   "Set-Cookie";
      proxy_intercept_errors on;
      proxy_pass https://${aws_s3_bucket_region}/${aws_s3_bucket}/; # Edit your Amazon S3 Bucket name
      expires 1y;
      log_not_found off;
    }
  }    
}
EOF

##################
#  Docker  Setup # 
##################

echo "Docker setup"

yum -y install docker-engine

systemctl start docker

curl -L https://github.com/docker/compose/releases/download/1.7.0-rc1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

########################
#  Docker compose file #
########################

cat << EOF > /opt/app/docker-compose.yml
nginx:
  image: nginx:latest
  restart: always
  container_name: nginx
  ports:
    - "80:80"
    - "8080:8080"
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    - ./nginx/test_site_access.log:/var/log/nginx/test_site_access.log
    - ./nginx/htpasswd:/etc/nginx/htpasswd
    - /etc/localtime:/etc/localtime:ro
  links:
      - kibana
elasticsearch:
  image: elasticsearch:latest
  restart: always
  container_name: elasticsearch
  command: elasticsearch -Des.network.host=0.0.0.0
  ports:
    - "9200:9200"
    - "9300:9300"
  volumes:
    - /usr/share/elasticsearch/data
    - /etc/localtime:/etc/localtime:ro
logstash:
  image: logstash:latest
  restart: always
  container_name: logstash
  command: logstash -f /etc/logstash/conf.d/logstash.conf
  volumes:
    - ./logstash/logstash.conf:/etc/logstash/conf.d/logstash.conf
    - ./nginx/test_site_access.log:/var/log/nginx/test_site_access.log:ro
    - /etc/localtime:/etc/localtime:ro
  ports:
    - "5000:5000"
  links:
    - elasticsearch
kibana:
  image: kibana
  restart: always
  container_name: kibana
  volumes:
    - /etc/localtime:/etc/localtime:ro
  ports:
    - "5601:5601"
  links:
    - elasticsearch
  environment:
    - ELASTICSEARCH_URL=http://elasticsearch:9200   
EOF

docker-compose -f /opt/app/docker-compose.yml up -d

systemctl enable docker.service

date
echo "Setup complete - rebooting"

touch /tmp/cloudinit.complete 
shutdown -r now       

} > $LOG_FILE 2>&1