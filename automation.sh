sudo apt update -y

dpkg -s apache2

if [ $? > 0 ]; then
apt-get install apache2 -y
systemctl start  apache2
systemctl enable apache2
fi

act=$(systemctl is-active apache2)
if [ "$act" != "active" ]; then
service apache2 start
fi

systemctl is-enabled apache2
if [ $? -ne 0 ]; then
systemctl enable apache2
fi

dpkg -s awscli
if [ $? -ne 0 ]; then
sudo apt install awscli -y
fi

name=kabir
dt=$(date "+%Y.%m.%d-%H.%M.%S")
tar -cvf /tmp/$name-httpd-logs-$dt.tar /var/log/apache2

#fz=$(stat -c %s "/tmp/$name-httpd-logs-$dt.tar")
fz=$(ls -l --block-size=M /tmp/$name-httpd-logs-$dt.tar | awk '{print $5}')

aws s3 cp /tmp/$name-httpd-logs-$dt.tar s3://upgrad-kabirgarhwal/$name-httpd-logs-$dt.tar

inventory_file=/var/www/html/inventory.html
if [ ! -f "$inventory_file" ]
then
touch "$inventory_file"
echo "Log Type&emsp;&emsp;&emsp;&emsp;Time Created&emsp;&emsp;&emsp;&emsp;Type&emsp;&emsp;&emsp;&emsp;Size &emsp;&emsp;&emsp;&emsp;<br>" >> "$inventory_file"
fi
echo "<br>" >> $inventory_file

echo "httpd-logs&emsp;&emsp;&emsp;"$dt"&emsp;&emsp;&nbsp;&nbsp;tar&emsp;&emsp;&emsp;&emsp;"$fz"&emsp;&emsp;&emsp;<br>" >> "$inventory_file"

cron_file="/etc/cron.d/automation"

if [ ! -f "$cron_file" ]
then
touch "$cron_file"
echo "00 00 * * * root /root/Automation_Project/automation.sh" > "$cron_file"
fi
