# Set up of Cognos Analytics 11.1 with DB2-C and Cloudera quickstart on Docker Compose
---
##Example of Dockerfile to setup Cognos 11.1 in a container
__WARNING__: The resulting docker image is not suitable for any production use and should be used for demonstration purposes only

##Copyright 2019, IBM Corporation

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

---

## Overview
This Docker image build on top of the Cognos 11.1/Centos 7 with DB2-developer-C image, and adds Cloudera QuickStart to it.

<a name="prereqs"></a>__Prerequisites__:
 - Docker (with docker-compose) installed locally
 - See the Cognos 11.1 specific prereqs in [phg-centos7-xfce-cognos\README_Cognos_setup_docker.md](phg-centos7-xfce-cognos\README_Cognos_setup_docker.md#prereqs)
 - Access to the Cloudera Quickstart docker image

The `docker-compose.yml` file in this directory sets up the Cloudera QuickStart docker image in the same docker-compose set as Cognos Analytics 11.1

## Setting up Cognos 11.1 docker-compose environment
See [phg-centos7-xfce-cognos\Cognos_setup_docker.md](phg-centos7-xfce-cognos\README_Cognos_setup_docker.md) for instructions to get Cognos 11.1 setup with DB2-C on docker.

## Setting up Cloudera quickstart docker
 * Download from Cloudera their quickstart docker image, see https://www.cloudera.com/downloads/quickstart_vms/5-13.html
   https://downloads.cloudera.com/demo_vm/docker/cloudera-quickstart-vm-5.13.0-0-beta-docker.tar.gz
 * Unpack image ungzip, to get the `tar`, using e.g. `7z x cloudera-quickstart-vm-5.13.0-0-beta-docker.tar.gz` 
 * Import and tag image into local Docker: `docker import cloudera-quickstart-vm-5.13.0-0-beta-docker\cloudera-quickstart-vm-5.13.0-0-beta-docker.tar cloudera/quickstart:import`
 * Verify the image using `docker images`

 * For testing purposes, you may want to start image the image stand-alone, exposing ports 80, 8888, 7180: `docker run --name clouderaqs --hostname=quickstart.cloudera --privileged=true -p 8888:8888 -p 7180:7180 -p 80:80 -td cloudera/quickstart:import /bin/bash -c "/usr/bin/docker-quickstart && /bin/bash"`
 * Tail the log using `docker logs -f clouderaqs`
 * Ports used by the image: 
  * 80: Welcome
  * 8888: Hue
  * 7180: ?
  * 12000/12001: sqoop
  * 11000/11001/11443: oozie
* Once started, you should get the Cloudera welcome page on HTTP port 80 http://localhost, from there you can link the Hue interface at http://localhost:8888 (user `cloudera`, pw: _cloudera_)
  * Stop and remove the container with `docker stop clouderaqs` and `docker rm clouderaqs`

## Running the docker-compose assembly
To start all 3 containers in one go:
* Follow above instructions to getting the DB2-developer-C image, the Cloudera-QuickStart image and the Cognos Analytics 11 builds
* Use `docker-compose up -d` to bring up the assembly.
* You may monitor the bring-up process with `docker-compose logs -f` or individually for each container:
  * `docker-compose logs -f db2-c` should eventually show the CM database:
  ```
  db2server       | Database 1 entry:
  db2server       |
  db2server       |  Database alias                       = CM
  db2server       |  Database name                        = CM
  ``` 
  *  `docker-compose logs -f cognosca11_1` until you get a line that reads:
  ```
  cognos11cnr     | INFO, "[main]", "Silent Execution Mode (end)"
  ```
  *  `docker-compose logs -f cloudera_qs` until:
  ```
  cloudera_qs     | Started Impala Server (impalad):[  OK  ]
  ```

### Post-config steps