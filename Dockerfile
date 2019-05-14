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

USER $NB_UID
# Add HANA Client Tool (2.4.126) and PIP package
RUN mkdir ~/hdbinstaller && \
    tar -xvzf /setupfiles/hanaclient-2.4.126-linux-x64.tar.gz -C $HOME/hdbinstaller && \
    rm /setupfiles/hanaclient-2.4.126-linux-x64.tar.gz && \
    ~/hdbinstaller/client/hdbinst --path=$HOME/sap/hdbclient

# Install hdbcli Python library
RUN pip install file://$HOME/sap/hdbclient/hdbcli-2.4.126.tar.gz