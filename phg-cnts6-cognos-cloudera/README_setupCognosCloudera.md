# Set up of Cognos Analytics 11.1 with DB2-C and Cloudera quickstart on Docker Compose

Prereq: have docker locally installed

The `docker-compose.yml` file in this directory sets up the Cloudera QuickStart docker image in the same docker-compose set as Cognos Analytics 11.1

## Setting up Cognos 11.1 docker-compose environment
See [phg-vnc-centos6-gnome-cognos\Cognos_setup_docker.md](phg-vnc-centos6-gnome-cognos\Cognos_setup_docker.md) for instructions to get Cognos 11.1 setup with DB2-C on docker.

## Setting up Cloudera quickstart docker
 * Download from Cloudera their quickstart docker image, see https://www.cloudera.com/downloads/quickstart_vms/5-13.html
   https://downloads.cloudera.com/demo_vm/docker/cloudera-quickstart-vm-5.13.0-0-beta-docker.tar.gz
 * Unpack image twice (ungzip, then untar), using e.g.:
    1. `7z x cloudera-quickstart-vm-5.13.0-0-beta-docker.tar.gz` 
	  2. `7z x cloudera-quickstart-vm-5.13.0-0-beta-docker.tar`
 * Import image into local Docker: `docker import cloudera-quickstart-vm-5.13.0-0-beta-docker\cloudera-quickstart-vm-5.13.0-0-beta-docker.tar`
 * Get image's ID: `docker images`, you get e.g.: `19b13857aca8`
 * Tag image from ID: `docker tag 19b13857aca8 cloudera/quickstart:import`, so it can be refered to by this name `cloudera/quickstart:import` instead of ID

 * For testing purposes, you may want to start image the image stand-alone, exposing ports 80, 8888, 7180: `docker run --hostname=quickstart.cloudera --privileged=true -p 8888:8888 -p 7180:7180 -p 80:80 -ti cloudera/quickstart:import /usr/bin/docker-quickstart` 
   * To just get the shell and then run `docker-quickstart`: `docker run --hostname=quickstart.cloudera --privileged=true -p 8888:8888 -p 7180:7180 -p 80:80 -t -i cloudera/quickstart:import /bin/bash -c "/usr/bin/docker-quickstart && exec bash"`
   * Ports used by the image: 
     * 80: Welcome
     * 8888: Hue
     * 7180: ?
   * Find container ID which is running image: `docker ps`, getting e.g. `8f4e0f2be311`
   * Once started, you should get the Cloudera welcome page on HTTP port 80 http://localhost

## Running the docker-compose assembly
To start all 3 containers in one go:
* Follow above instructions to getting the DB2-developer-C image, the Cloudera-QuickStart image and the Cognos Analytics 11 build
* Use `docker-compose up -d`. You may monitor the bring-up process with `docker-compose logs -f`
  * Follow the configuration procedure for Cognos11.1 and Content Manager DB creation in DB2-C

### Post-config steps