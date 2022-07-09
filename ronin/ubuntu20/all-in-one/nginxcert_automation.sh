#!/bin/bash

# this script is currently run at every boot time by the crontab command
# @reboot sh /home/ubuntu/nginxcert_automation.sh

echo "Starting:" > automation_stats.txt
date >> automation_stats.txt

echo > install_log.txt

\rm stage1.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage1.sh
chmod +x stage1.sh
./stage1.sh >> install_log.txt 2>&1

\rm stage2.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage2.sh
chmod +x stage2.sh
./stage2.sh >> install_log.txt 2>&1


#Add conda and jupyterlab base (some to be replaced by modules)
if [ ! -d /home/ubuntu/miniconda3 ]; then
  \rm -fr Miniconda3-py39_4.10.3-Linux-x86_64.sh miniconda3
  \rm -fr environment.yml
  wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/environment.yml
  wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
  chmod +x Miniconda3-py39_4.10.3-Linux-x86_64.sh
  ./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p miniconda3
  . miniconda3/bin/activate
  conda env create -f environment.yml
fi

#Install Jupyter lab service bits including helper scripts and setting env
\rm -fr get_free_port.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/get_free_port.sh
chmod +x get_free_port.sh

\rm -fr start_jupyter.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/start_jupyter.sh
chmod +x start_jupyter.sh

mkdir -p /home/ubuntu/.jupyter/
(
. /home/ubuntu/miniconda3/bin/activate mit-ronin-conda-2022a
env | grep -e '^CONDA_EXE' -e '^CONDA_PREFIX' -e '^CONDA_PROMPT_MODIFIER' -e '^PROJ_LIB' -e '^CONDA_PYTHON_EXE' -e '^CONDA_DEFAULT_ENV' -e '^PATH' > /home/ubuntu/.jupyter/env
)

(
cat <<'EOFA'
       # service name:     jupyter-lab.service 
       # path:             /lib/systemd/system/jupyter-lab.service

       [Unit]
       Description=Jupyter Lab Server

       [Service]
       Type=simple
       PIDFile=/run/jupyter-lab.pid

       EnvironmentFile=/home/ubuntu/.jupyter/env

       # Jupyter Notebook: change PATHs as needed for your system
       # ExecStart=/home/ubuntu/miniconda3/envs/mit-ronin-conda-2022a/bin/jupyter-lab --no-browser --ServerApp.token='' --ServerApp.password='' --ServerApp.ip='*'
       # ExecStart=/home/ubuntu/miniconda3/envs/mit-ronin-conda-2022a/bin/jupyter-lab --no-browser --ServerApp.token='' --ServerApp.password=''
       ExecStart=/home/ubuntu/start_jupyter.sh

       User=ubuntu
       Group=ubuntu
       WorkingDirectory=/home/ubuntu
       Restart=always
       RestartSec=10

       [Install]
       WantedBy=multi-user.target
EOFA
) | sudo tee /lib/systemd/system/jupyter-lab.service
sudo chmod 755 /lib/systemd/system/jupyter-lab.service
sudo systemctl enable jupyter-lab
sudo systemctl start  jupyter-lab


#Tweak nginx to allow longer names
ngin_hash_wc=`grep server_names_hash_bucket_size /etc/nginx/nginx.conf | grep 128 | wc -l`
if [ ${ngin_hash_wc} -eq "0" ]; then
cp /etc/nginx/nginx.conf .
ed nginx.conf <<'EOFA'
/server_names_hash_bucket_size
a
	server_names_hash_bucket_size 128;
.
w
q
EOFA
sudo cp nginx.conf /etc/nginx/nginx.conf
fi
sudo systemctl restart nginx

#Install apache and set running on non-standard ports (used for lua dynamic connections to services)
sudo mkdir -p /usr/sbin/
(
cat <<'EOF'
#!/bin/sh
exit 101
EOF
) | sudo tee /usr/sbin/policy-rc.d
sudo chmod 755 /usr/sbin/policy-rc.d
sudo apt-get install -y apache2
\rm 000-default-conf.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/000-default-conf.template
sudo /bin/cp 000-default-conf.template /etc/apache2/sites-available/000-default.conf
\rm ports.conf.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/ports.conf.template
sudo /bin/cp ports.conf.template /etc/apache2/ports.conf
sudo rm -f /usr/sbin/policy-rc.d
sudo systemctl start apache2

#Add features for auth pages

# o allow www-data to su
(
cat <<'EOFA'
www-data ALL=(ALL) NOPASSWD:ALL
EOFA
) | sudo tee /etc/sudoers.d/91-www-data-users

# o add address for auth.localhost
auth_etc=`grep 'auth\.localhost' /etc/hosts | wc -l`
if [ ${auth_etc} -eq "0" ]; then
(
cat <<'EOFA'

#added by SCITC provisioning
127.0.0.1 auth.localhost
EOFA
) | sudo tee -a /etc/hosts
fi

# o add nginx server record for auth.localhost
auth_sites=`grep 'server_name *auth\.localhost' /etc/nginx/sites-available/default-http | wc -l`
if [ ${auth_sites} -eq "0" ]; then
(
cat <<'EOFA'

server {
    server_name auth.localhost;
    root /var/www/html/;
    access_log /var/log/nginx/auth.localhost.access.log;
    error_log /var/log/nginx/auth.localhost.error.log;
    index auth_index.php;
        location / {
          try_files $uri $uri/ /auth_index.php?$args;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }
}

EOFA
) | sudo tee -a /etc/nginx/sites-available/default-http
fi


echo "Ending:" >> automation_stats.txt
date >> automation_stats.txt


