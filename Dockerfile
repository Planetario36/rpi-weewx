#-------------------------------------------------------
#
# Dockerfile for building a simulator driver weewx system
#
# build via 'docker build -t weebuntu'
#
# run via 'docker -p 22 -p 80 run -t weebuntu'
#     and optionally add -d to run detached in the backgroud
#     or optionally add -t -i to monitor it in the foreground
#
# or 'docker run -i -t weebuntu /bin/bash'
#     and in the shell 'service start' nginx and weewx
#
# this Dockerfile sets root's password = root
# and permits root logins over ssh for debugging
#
# last modified:
#     2016-0505 - update to 3.5.0
#     2015-1211 - install pyephem, refactor to reduce layers
#     2015-1206 - update to 3.3.1
#     2015-0220 vinceskahan@gmail.com - original
#
#-------------------------------------------------------

FROM resin/rpi-raspbian:jessie
MAINTAINER Drew McCalmont "dmmccalmont@gmail.com"
EXPOSE 22
EXPOSE 80

# DANGER WILL ROBINSON !!!!
# set root's password to something trivial
ENV ROOT_PASSWORD p@ssword1
RUN echo "root:$ROOT_PASSWORD" | chpasswd


#---- uncomment to set your timezone to other than UTC
ENV TIMEZONE="US/Eastern"
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# sshd needs its /var/run tree there to successfully start up
RUN mkdir -p /var/run/sshd

# copy supervisor config file into place
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#setup usb drive
RUN sudo mkdir -p /media/WXdisk
#RUN mount -t ext4 -o defaults /dev/sda1 /media/WXdisk
RUN echo "/dev/sda1 /media/WXdisk ext4 defaults 0" >> /etc/fstab


# install misc packages, webserver, weewx prerequisites, pip, supervisord/sshd
# then install pyephem via pip
# then install weewx via the setup.py method
#  - the 'cd' below expects Tom to stick with the weewx-VERSION naming in his .tgz


ENV WEEWX_VERSION weewx_3.5.0-1_all.deb

RUN apt update && apt install -y sqlite3 wget curl procps cron gcc emacs rsyslog \
        python-configobj python-cheetah python-imaging python-serial python-usb python-dev \
        python-pip \
        supervisor openssh-server
RUN apt -f install
RUN pip install pyephem
RUN wget http://weewx.com/downloads/$WEEWX_VERSION -O /tmp/weewx.deb && \
        dpkg -i /tmp/weewx.deb



RUN wget http://lancet.mit.edu/mwall/projects/weather/releases/weewx-exfoliation-0.35.tgz \
    -O /tmp/exfoliation.tgz
RUN wee_extension --install /tmp/exfoliation.tgz

RUN wget http://lancet.mit.edu/mwall/projects/weather/releases/weewx-forecast-3.0.8.tgz -O /tmp/forecast.tgz
RUN wee_extension --install /tmp/forecast.tgz

#copy correct settings
RUN rm /etc/weewx/weewx.conf
COPY weewx.conf /etc/weewx/

#start weewx
RUN /etc/init.d/weewx stop
RUN /etc/init.d/weewx start


#Webcam upload
RUN mkdir /home/wunderground_upload_cam
COPY wunderground_upload_cam /home/wunderground_upload_cam
RUN crontab -l | { cat; echo "*/2 * * * * python /home/wunderground_upload_cam/wunderground_upload_cam.py"; } | crontab -


# call supervisord as our container process to run
#CMD ["/usr/bin/supervisord"]

# or use bash instead (and manually run supervisord) for debugging
CMD ["/bin/bash"]
