FROM ubuntu:18.04 as ubuntu-base
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        gnome-system-monitor \
        xfce4-terminal \
        binutils \
        gdebi \
        xz-utils \
        python-gtk2 \
        supervisor \
        xvfb x11vnc novnc websockify \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html
COPY scripts/* /opt/bin/
# Add Supervisor configuration file
COPY supervisord.conf /etc/supervisor/
# Relaxing permissions for other non-sudo environments
RUN  mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 777 /opt/bin/ /var/run/supervisor /var/log/supervisor /etc/passwd \
    && chgrp -R 0 /opt/bin/ /var/run/supervisor /var/log/supervisor \
    && chmod -R g=u /opt/bin/ /var/run/supervisor /var/log/supervisor
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
CMD ["/opt/bin/entry_point.sh"]
#============================
# Utilities
#============================
FROM ubuntu-base as ubuntu-utilities
RUN apt-get -qqy update \
    && apt-get install firefox \
    && apt-get autoclean \
    && apt-get autoremove
#============================
# GUI
#============================
FROM ubuntu-utilities as ubuntu-ui
ENV SCREEN_WIDTH=1300 \
    SCREEN_HEIGHT=620 \
    SCREEN_DEPTH=24 \
    SCREEN_DPI=96 \
    DISPLAY=:99 \
    DISPLAY_NUM=99 \
    UI_COMMAND=/usr/bin/startxfce4
RUN apt-get update -qqy \
    && apt-get -qqy install --no-install-recommends \
        dbus-x11 xfce4 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
