# Setting up Cognos Analytics 11.1 in a container environment
---
##Copyright 2019, IBM Corporation

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

Written by Philippe Gregoire - IBM Ecosystem Advocacy Group Europe (philippe.gregoire@fr.ibm.com)

---

The contents of this repository provides material that allows to setup Cognos Analytics in a containerized environment.

**WARNING**: _The resulting containers are intended for demonstration purposes only and are **not** intended to run for any production grade application!!_

---

### Required Licenses
The software licenses and binaries used to build those images can be obtained from publicly available sources, such as DockerHub and IBM Passport Advantage

## Project structure
The containers are driven by `docker-compose` configuration files.
There are currently two setups, refer to the setup instructions in each subfolder:
1. **Cognos Analytics 11.1** with **DB2-Developer-C** in [phg-centos7-xfce-cognos-cloudera\phg-centos7-xfce-cognos](phg-centos7-xfce-cognos-cloudera\phg-centos7-xfce-cognos\README_Cognos_setup_docker.md)
2. **Cognos Analytics 11.1** with **DB2-Developer-C** and **Cloudera Quickstart 5.13** in [phg-centos7-xfce-cognos-cloudera](phg-centos7-xfce-cognos-cloudera\README_setupCognosCloudera.md)