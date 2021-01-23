FROM ubuntu:18.04
LABEL description="ROS melodic on Ubuntu:18"

ARG username=user
ARG wkdir=/home/work
# ARG ros_master_uri=
ARG ros_pkg=https://github.com/codetyt/for_net_test.git
ARG dirname=for_net_test

# apt-get update
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends tzdata

# timezone setting
ENV TZ=Asia/Tokyo

# apt-install 
RUN apt-get install -y --no-install-recommends sudo curl gnupg git vim lsb-release

# add new user
# echo "username:password" | chpasswd
# root password is "root"

RUN echo "root:root" | chpasswd && \
    adduser --disabled-password --gecos "" "${username}" && \
    echo "${username}:${username}" | chpasswd && \
    echo "%${username}    ALL=(ALL)   NOPASSWD:    ALL" >> /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username} 
    
WORKDIR ${wkdir}
RUN chown ${username}:${username} ${wkdir}
USER ${username}

#ROS installation
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install -y --no-install-recommends ros-melodic-ros-base
# or "RUN sudo apt install ros-melodic-desktop-full" for GUI

SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN source ~/.bashrc
RUN source /opt/ros/melodic/setup.bash
RUN sudo apt-get install -y --no-install-recommends \
    python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo rosdep init && rosdep update

# RUN echo "export ROS_MASTER_URI=http://${ros_master_uri}:11311/" >> ~/.bashrc
# RUN echo "export ROS_IP=`hostname -I | cut -d' ' -f1`" >> ~/.bashrc
RUN source ~/.bashrc
RUN git clone ${ros_pkg}
WORKDIR ${wkdir}/${dirname}
RUN source devel/setup.bash && rm -rf ./build && catkin_make
