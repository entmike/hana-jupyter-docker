# hana-jupyter-docker

# About
Jupyter Docker Image with HANA libs.

Built on the shoulders of [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html) ([jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook))

# Libraries Included

- Everything present in [jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook)
## HANA-Specific Additions
- HANA Python [`pyhdb`](https://github.com/SAP/PyHDB), [`hdbcli`](https://help.sap.com/viewer/0eec0d68141541d1b07893a39944924e/2.0.02/en-US/f3b8fabf34324302b123297cdbe710f0.html), and [`sqlalchemy-hana`](https://github.com/SAP/sqlalchemy-hana) libraries
- HANA NodeJS [`@sap/hana-client`](https://help.sap.com/viewer/0eec0d68141541d1b07893a39944924e/2.0.02/en-US/58c18548dab04a438a0f9c44be82b6cd.html) npm library
- [SAP HANA Client `2.4.126`](https://tools.hana.ondemand.com/#hanatools)

## Kernel Additions
- [`ijavascript`](https://www.npmjs.com/package/ijavascript) (NodeJS Kernel)

## Other Additions
- [`pixiedust`](https://github.com/pixiedust/pixiedust) and [`pixiedust_node`](https://github.com/pixiedust/pixiedust_node)
- [`sqlalchemy`](https://github.com/sqlalchemy/sqlalchemy) and [`ipython-sql`](https://github.com/catherinedevlin/ipython-sql)
- [`@jupyter-widgets/jupyterlab-manager`](https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager) and [`jupyter-matplotlib`](https://github.com/matplotlib/jupyter-matplotlib)

# Sample Notebooks Included
| Notebook | Description | Docs/Credits |
| -------- | ----------- | ------------ |
| `hdbcli Sample.ipynb` | Demonstrates using the `hdbcli` Python Library | [Based on Documentation on SAP Help](https://help.sap.com/viewer/0eec0d68141541d1b07893a39944924e/2.0.02/en-US/f3b8fabf34324302b123297cdbe710f0.html) |
| `pyhdb Sample.ipynb` | Demonstrates using the `pyhdb` Python Library | https://github.com/SAP/PyHDB |
| `NodeJS Kernel Sample.ipynb` | Demonstrates using `@sap/hana-client` npm module in `ijavascript` Kernel | [Based on Examples on Github](https://github.com/SAP/PyHDB#getting-started) |
| `sqlalchemy Sample.ipynp` | Demonstrates using `sqlalchemy` SQL Magic on HANA DB | Credits to [@adadouche](https://github.com/adadouche) [document](https://developers.sap.com/tutorials/mlb-hxe-tools-jupyter.html) to produce sample |
| `MatPlot Sample.ipynb` | Simple Reference MatPlot Example | [Chris Moffit article 'Simple Graphing with IPython and Pandas'](https://pbpython.com/simple-graphing-pandas.html) |
| `MatPlot Sample2.ipynb` | Another Simple Reference MatPlot Example | [Chris Moffit article 'Simple Graphing with IPython and Pandas'](https://pbpython.com/simple-graphing-pandas.html) |

# Usage Examples

## Running emphermal storage container
The following example shows:

- Running a container with the work directory mounted to an example `/appdata/notebooks` folder.
- Exposing Jupyter Notebook webserver on port `10000`
- Running on a Docker Network called `YourDockerNetwork` (Useful if you are running HANA Express in a Container on a Docker Network, for example.)
```bash
docker run --rm --network YourDockerNetwork \
-p 10000:8888 \
-v /appdata/notebooks:/home/jovyan/work \
-e JUPYTER_ENABLE_LAB=yes \ 
entmike/hana-jupyter-notebook:latest
```
## Docker Compose
The following example will spin up both the Jupyter Notebook and also a HANA Express Edition Container.

***Note*** Be sure to set the environment variable `HXE_MASTER_PASSWORD` before deploying.
```
version: '2'

services:
  jupyter:
    image: entmike/hana-jupyter-notebook:latest
    depends_on:
      - hxehost
      
  hxehost:
    image: store/saplabs/hanaexpress:2.00.036.00.20190223.1
    hostname: hxe
    volumes:
      - hana-express:/hana/mounts
    command: --agree-to-sap-license --master-password ${HXE_MASTER_PASSWORD}
```
