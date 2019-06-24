# Use an official Jupyter Data Science Notebook as a parent image
FROM jupyter/datascience-notebook:latest

LABEL Maintainer="Mike Howles <mike.howles@gmail.com>"

# Configure SAP Hana Node Client for NodeJS Kernel use
RUN npm config set @sap:registry https://npm.sap.com  && \
    npm i @sap/hana-client && \
# Add Python Node Kernel
    npm i -g ijavascript && \
    ijsinstall

# Install PyHDB
RUN pip install pyhdb && \
# Install PixieDust Helper Libs
    pip install pixiedust && \
    pip install pixiedust_node && \
# Install SQL Alchemy
    pip install sqlalchemy sqlalchemy-hana ipython-sql

# Install MatplotLib
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyter-matplotlib

# Copy over some sample notebooks
COPY ./samples /home/jovyan/samples
COPY ./hanaclient-2.4.126-linux-x64.tar.gz /setupfiles/hanaclient-2.4.126-linux-x64.tar.gz
# Change ownership
USER root
RUN chown $NB_UID ./samples/*
RUN chown -Rf $NB_UID /setupfiles

# Temporarily add jessie backports to get openjdk 8, but then remove that source
# Java 8 is a dependency of the Athena JDBC driver
RUN echo 'deb http://cdn-fastly.deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get -y update && \
    apt-get install --no-install-recommends -t jessie-backports -y openjdk-8-jdk openjdk-8-jre-headless ca-certificates-java && \
    rm /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    /usr/sbin/update-java-alternatives -s java-1.8.0-openjdk-amd64

USER $NB_USER

RUN conda install --quiet --yes 'r-rjava'

# By default R fails to find jni.h so we specify the include directory manually
RUN R CMD javareconf JAVA_CPPFLAGS=-I/usr/lib/jvm/default-java/include

# Installing RJDBC fails unless we set the LD_LIBRARY_PATH to point to paths containing libjvm.so
ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64

COPY rjdbc.R /tmp
RUN R -f /tmp/rjdbc.R

COPY athena.R /tmp
RUN R -f /tmp/athena.R

USER $NB_UID
# Add HANA Client Tool (2.4.126) and PIP package
RUN mkdir ~/hdbinstaller && \
    tar -xvzf /setupfiles/hanaclient-2.4.126-linux-x64.tar.gz -C $HOME/hdbinstaller && \
    rm /setupfiles/hanaclient-2.4.126-linux-x64.tar.gz && \
    ~/hdbinstaller/client/hdbinst --path=$HOME/sap/hdbclient

# Install hdbcli Python library
RUN pip install file://$HOME/sap/hdbclient/hdbcli-2.4.126.tar.gz