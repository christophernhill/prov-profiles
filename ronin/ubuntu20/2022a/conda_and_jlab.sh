wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
chmod +x Miniconda3-py39_4.10.3-Linux-x86_64.sh
./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p miniconda3 
. miniconda3/bin/activate 
conda env create -f environment.yml
