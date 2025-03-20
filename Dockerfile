FROM x11vnc/docker-desktop

# 
ENV PYPI_INDEX=https://pypi.vnpy.com
ENV DOCKER_CMD=startvnc.sh

# 
USER root
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    python3-pip \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fonts-noto-cjk \
    libxcb-xinerama0 \
    qtbase5-dev \
    qtchooser \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 
RUN locale-gen zh_CN.GB18030

# 
RUN cd /tmp \
    && wget https://pip.vnpy.com/colletion/ta-lib-0.4.0-src.tar.gz \
    && tar -xf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib \
    && ./configure --prefix=/usr/local \
    && make -j1 \
    && make install \
    && cd / \
    && rm -rf /tmp/ta-lib* \
    && ldconfig

# 
RUN mkdir -p /home/ubuntu/veighna && \
    chown -R ubuntu:ubuntu /home/ubuntu/veighna

# 
USER ubuntu
WORKDIR /home/ubuntu/veighna

# 
RUN python3 -m pip install --upgrade pip wheel --index $PYPI_INDEX

# 
RUN python3 -m pip install numpy==1.23.1 --index $PYPI_INDEX

# 
RUN python3 -m pip install ta-lib==0.4.24 --index $PYPI_INDEX

# 
COPY --chown=ubuntu:ubuntu requirements.txt .
RUN python3 -m pip install -r requirements.txt --index $PYPI_INDEX \
    && echo 'export QT_SELECT=qt5' >> /home/ubuntu/.bashrc \
    && echo 'export QT_SELECT=qt5' >> /home/ubuntu/.zshrc \

# 
COPY --chown=ubuntu:ubuntu . .

# 
RUN python3 -m pip install . --index $PYPI_INDEX

# 
USER root

# 
ENV DOCKER_CMD=startvnc.sh
CMD ["$DOCKER_CMD"]
