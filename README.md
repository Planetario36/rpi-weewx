# Docker implementation of weewx for FineOffSetUSB

This small set of files lets you spin up a working Docker instance of weewx on top of Raspbian within just a few minutes.

You can easily get Docker for Raspberry Pi by using [HypriotOS](http://blog.hypriot.com/).  This Docker repo may be easily modified to work with Resin.io, but hopefully they will better support USB storage in the future.  I have the Weather databases saved in the volume /media/WXdisk.  You will have to link the volume on your host machine to the container for this to work properly.

The root password is 'root' which you should of course change to something suitably obscure for you.

Yes, I called the resulting image 'rpi-weewx' :-)

## build instructions

    make a working directory
    cd into there
    copy the contents of this repo into that directory

### modify files for your configuration
* Dockerfile —if you would like to enable webcam upload
* weewx.conf —Weather station settings
* wunderground_upload_cam.conf —if you would like to use webcam uploader

### build the image with the desired image tag name
    docker build -t WXpiimage .

### verify your image is available in docker

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    weebian             latest              62ae86bf4f67        14 hours ago        323.6 MB
    debian              latest              4d6ce913b130        4 days ago          84.98 MB

### run the image in a new container
    $ run -dit --name wxpi --privileged -p 22 -v /media/WXdisk:/media/WXdisk  --restart always WXpiimage
    00a256c24b2b97342fc8a5768e1aeab6cfa6d17df159550e738319dded6c8931
    $ docker ps -a
    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                          NAMES
    00a256c24b2b        weebian:latest      "/usr/bin/supervisor   9 seconds ago       Up 8 seconds
    0.0.0.0:49228->22/tcp, 0.0.0.0:49229->80/tcp   drunk_jang

### to expose ports to the local host
    $ run -dit --name wxpi --privileged -p 2201:22 -v /media/WXdisk:/media/WXdisk  --restart always WXpiimage
    (this exposes container port 22 to localhost 2201)


See the Dockerfile here for more info at the top...
