#!/bin/bash

yum update -y
yum install -y install git
echo "hello from instance $(hostname)" > /var/www/html/index.html
systemctl start httpd && systemctl enable httpd