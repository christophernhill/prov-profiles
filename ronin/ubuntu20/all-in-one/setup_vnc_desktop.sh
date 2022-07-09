#!/bin/bash
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 tigervnc-standalone-server novnc websockify
mkdir -p /home/ubuntu/.vnc
cat > /home/ubuntu/.vnc/xstartup <<'EOFA'
#!/bin/bash
startxfce4 &
EOFA
chmod u+x /home/ubuntu/.vnc/xstartup

# this needs to run as ubuntu
# vncserver -localhost yes -geometry 1024x768 -SecurityTypes None  :0
vncserver -localhost yes -geometry 1024x768 -SecurityTypes None  :0
sudo /usr/bin/websockify  -D --verbose    --web /usr/share/novnc/     6080     localhost:5900 --log-file=/var/log/websockify
apt-get install -y xterm

# Fix silly terminal problem
cat > /home/ubuntu/.config/xfce4/panel/launcher-17/*.desktop <<'EOFA'
[Desktop Entry]
Version=1.0
Type=Application
Exec=dbus-launch gnome-terminal
# Exec=xeyes
Icon=utilities-terminal
StartupNotify=true
Terminal=false
Categories=Utility;X-XFCE;X-Xfce-Toplevel;
OnlyShowIn=XFCE;
X-AppStream-Ignore=True
Name=Terminal Emulator
Comment=Use the command line
X-XFCE-Source=file:///usr/share/applications/exo-terminal-emulator.desktop
Path=
EOFA
# chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/panel/launcher-17/*.desktop
