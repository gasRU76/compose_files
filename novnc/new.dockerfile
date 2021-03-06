FROM alpine:edge
COPY config /etc/skel/.config
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing"  >> /etc/apk/repositories && \
  apk -U --no-cache add xvfb x11vnc@testing xfce4 xfce4-terminal firefox@testing python bash sudo curl docker ca-certificates wget && \
  addgroup alpine && \
  adduser -G alpine -s /bin/bash -D alpine && \
  echo "alpine:alpine" | /usr/sbin/chpasswd && \
  echo "alpine ALL=NOPASSWD: ALL" >> /etc/sudoers && \
  update-ca-certificates

USER alpine

ENV USER=alpine \
    DISPLAY=:1 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=/home/alpine \
    TERM=xterm \
    SHELL=/bin/bash \
    VNC_PASSWD=Pa22word \
    VNC_PORT=5900 \
    VNC_RESOLUTION=1400x900 \
    VNC_COL_DEPTH=24  \
    NOVNC_PORT=6080 \
    NOVNC_HOME=/home/alpine/noVNC

RUN set -xe && \
  mkdir -p $NOVNC_HOME/utils/websockify && \
  wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $NOVNC_HOME && \
  wget -qO- https://github.com/novnc/websockify/archive/v0.8.0.tar.gz | tar xzf - --strip 1 -C $NOVNC_HOME/utils/websockify && \
  chmod +x -v $NOVNC_HOME/utils/*.sh && \
  ln -s $NOVNC_HOME/vnc_lite.html $NOVNC_HOME/index.html

WORKDIR $HOME
EXPOSE $VNC_PORT $NOVNC_PORT

COPY run_novnc /usr/bin/
CMD ["run_novnc"]
