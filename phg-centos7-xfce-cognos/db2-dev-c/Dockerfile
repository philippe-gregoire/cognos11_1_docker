################################################################################
# Example of Dockerfile to setup DB2 Dev C with the Cognos CM database
#
# WARNING: The resulting docker image is not suitable for any production 
#          use and should be used for demonstration purposes only
#
# Copyright 2019, IBM Corporation
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
FROM store/ibmcorp/db2_developer_c:11.1.4.4-x86_64

MAINTAINER Philippe Gregoire

# The regular entrypoint is /var/db2_setup/lib/setup_db2_instance.sh
# After setup it will look for scripts in /var/custom and execute them
# If the CM database exists, the /database/data/db2inst1/NODE0000/CM directory will also exist
COPY createDb.sql /var/cognos_cm/
COPY setup_DB2_CM.sh /var/custom/

RUN \
	sed -i 's/\r//g' /var/custom/setup_DB2_CM.sh && \
	chmod uo+x /var/custom/*.sh