#!/bin/bash
echo "Begin stage 3"

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

echo "End stage 3"
