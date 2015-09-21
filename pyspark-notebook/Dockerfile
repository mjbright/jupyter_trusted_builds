# Docker demo image, as used on try.jupyter.org and tmpnb.org

FROM jupyter/pyspark-notebook

MAINTAINER Michael Bright  <github.com@mjbright.net>

USER jovyan

# Install bash_kernel:
# Make sure not to create a cache dir else NB_UID switching
# will hit issues.
RUN /opt/conda/bin/pip install --no-cache-dir bash_kernel && \
    /opt/conda/bin/python -m bash_kernel.install

# Install RISE (LIVE Reveal) extension:
RUN cd /home/jovyan && \
    mkdir -p /home/jovyan/src/git && \
    cd /home/jovyan/src/git && \
    git clone https://github.com/damianavila/RISE /home/jovyan/src/git/damianvila.RISE && \
    cd /home/jovyan/src/git/damianvila.RISE && \
    python setup.py install

USER root

RUN groupadd -g 1000 docker && \
    usermod -a -G docker jovyan

# Setup sudoers without password:
ADD sudoers /etc/sudoers

# Needed so notebooks can write to mounted work volume:
RUN [ ! -d /home/jovyan/work ] && mkdir /home/jovyan/work; RET=0
RUN chown jovyan /home/jovyan/work && chmod a+w /home/jovyan/work

ADD docker /home/jovyan/work/docker
#RUN ./docker-1.8.2 daemon 2>/dev/null ; ls -altr /var/run/docker.sock

# Install setup ssh:
RUN apt-get update && apt-get install -y openssh-client
RUN mkdir -p /home/jovyan/.ssh
#RUN ssh-keygen -N '' -t dsa -i /home/jovyan/.ssh/id_dsa
## ADD ssh/id_dsa.pub ssh/id_dsa     /home/jovyan/.ssh/
## RUN chown jovyan home/jovyan/.ssh/id_dsa.pub home/jovyan/.ssh/id_dsa

#### # Install setup xdot: (for graphical display of GraphViz)
#### RUN apt-get install -y xdot

USER jovyan

# Install hide_code extension:
# - original not Python3 - git clone https://github.com/kirbs-/hide_code && \
RUN cd /home/jovyan/src/git && \
    git clone https://github.com/mjbright/hide_code && \
    cd /home/jovyan/src/git/hide_code && \
    python setup.py install

# Install nbgrader extension:
RUN apt-get install -y pandoc
RUN cd /home/jovyan/src/git && \
    git clone https://github.com/jupyter/nbgrader && \
    cd /home/jovyan/src/git/nbgrader && \
    python setup.py install
RUN nbgrader extension install --symlink && \
    nbgrader extension activate

USER root

