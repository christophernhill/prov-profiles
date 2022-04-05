#!/bin/bash
DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 tigervnc-standalone-server novnc websockify
mkdir -p /home/ubuntu/.vnc
cat > /home/ubuntu/.vnc/xstartup <<'EOFA'
#!/bin/bash
startxfce4 &
EOFA
chmod u+x /home/ubuntu/.vnc/xstartup
chown -R ubuntu:ubuntu /home/ubuntu/.vnc/
# this needs to run as ubuntu
# vncserver -localhost yes -geometry 1024x768 -SecurityTypes None  :0
su -l ubuntu /bin/bash -c "vncserver -localhost yes -geometry 1024x768 -SecurityTypes None  :0"
/usr/bin/websockify  -D --verbose    --web /usr/share/novnc/     6080     localhost:5900 --log-file=/var/log/websockify
apt install -y xterm
