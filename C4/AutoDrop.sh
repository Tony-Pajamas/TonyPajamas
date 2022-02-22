#!/bin/bash
#
# Dropbox 1 Autoconnect
# 

# Change Local Connect Per Dropbox Number, as well as -M number higher +2
# autossh -M 11166 -N -f -i /home/kv/.ssh/kv-red -R <CLOUD LOCAL CONNECT PORT>:localhost:22 tp@<CLOUD IP> -p <CLOUD SSH PORT>

#autossh -M 11166 -N -f -i /home/kv/.ssh/drop-d1 -R 9001:localhost:22 kv@ACSGSpace -p 443
#autossh -M 0 -N -f -i /home/drop/.ssh/drop-d1 -R 9001:localhost:22 kv@ACSGSpace -p 443
autossh -M 0 -N -f -i /home/drop/.ssh/drop-d1 -R 9001:localhost:22 kv@ACSGSpace -p 443
