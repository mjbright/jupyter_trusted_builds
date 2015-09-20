# Docker demo image, as used on try.jupyter.org and tmpnb.org

FROM jupyter/scipy-notebook

MAINTAINER Michael Bright  <github.com@mjbright.net>

USER jovyan

# Install bash_kernel:
# Make sure not to create a cache dir else NB_UID switching
# will hit issues.
RUN /opt/conda/bin/pip install --no-cache-dir bash_kernel && \
    /opt/conda/bin/python -m bash_kernel.install

# Install RISE (LIVE Reveal) extension:
RUN cd /home/jovyan && \
    mkdir -p src/git && \
    git clone https://github.com/damianavila/RISE src/git/damianvila.RISE && \
    cd src/git/damianvila.RISE && \
    python setup.py install

USER root

RUN groupadd -g 1000 docker && \
    usermod -a -G docker jovyan

# Setup sudoers without password:
ADD sudoers /etc/sudoers

ADD docker /home/joyvan/work/docker
#RUN ./docker-1.8.2 daemon 2>/dev/null ; ls -altr /var/run/docker.sock

# Install setup ssh:
RUN apt-get update && apt-get install -y openssh-client
RUN mkdir -p /home/joyvan/.ssh
#RUN ssh-keygen -N '' -t dsa -i /home/joyvan/.ssh/id_dsa
ADD ssh/id_dsa.pub ssh/id_dsa     /home/jovyan/.ssh/
RUN chown jovyan home/jovyan/.ssh/id_dsa.pub home/jovyan/.ssh/id_dsa

# Install setup xdot: (for graphical display of GraphViz)
RUN apt-get install -y xdot



