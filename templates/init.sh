#!/bin/bash

#Import Configs
cat <<EOT >>  /tmp/ocserv.conf
${ocserv_conf}
EOT
cat <<EOT >> /tmp/ocserv.socket
${ocserv_socket}
EOT



