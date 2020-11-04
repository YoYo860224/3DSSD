FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

# Install some basic utilities
RUN apt-get update 
RUN apt-get install -y apt-utils
RUN apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    tmux \
    htop \
    nano \
    vim \
    wget \
    zip

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
WORKDIR /home/user
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh \
 && chmod +x ~/Miniconda3-4.6.14-Linux-x86_64.sh\
 && ~/Miniconda3-4.6.14-Linux-x86_64.sh -b -p ~/miniconda \
 && rm ~/Miniconda3-4.6.14-Linux-x86_64.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda create -y --name py36 python=3.6.9 \
 && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
RUN /home/user/miniconda/bin/conda install conda-build=3.18.9=py36_3 \
 && /home/user/miniconda/bin/conda clean -ya

####################################################################################
# Other apt lib
RUN sudo apt-get install -y \
    build-essential \
    gcc-5 \
    g++-5 \
    libboost-all-dev \
    libopencv-dev

# Install
COPY ./requirements.txt ./requirements.txt
COPY ./tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl ./tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl
RUN pip install tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl
RUN pip install -r requirements.txt
RUN rm ./requirements.txt ./tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl

# Copy code
RUN mkdir 3DSSD
WORKDIR /home/user/3DSSD
COPY ./configs ./configs
COPY ./lib ./lib
COPY ./mayavi ./mayavi
COPY ./compile_all.sh ./compile_all.sh
RUN sudo chown -R user /home/user/3DSSD

# Compile cuda
RUN bash compile_all.sh ~/miniconda/envs/py36/lib/python3.6/site-packages/tensorflow /usr/local/cuda
ENV PYTHONPATH=$PYTHONPATH:/home/user/3DSSD/lib:/home/user/3DSSD/mayavi

####################################################################################
RUN sudo rm -rf /var/lib/apt/lists/*
