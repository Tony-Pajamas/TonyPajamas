#
#
#
# SCP to Clouds
#
# scp -P 443 -i /home/drop/.ssh/drop-d1 Main-Targeted.nmap kv@ACSGSpace:/home/kv/Drops

x=$(hostname | cut -d "2" -f 2)

if [[ "$x" == "D1" ]]; then
  k="drop-d1"
elif [[ "$x" == "D2" ]]; then
  k="drop-d2"
else
  echo "Unknown Drop Name"
  exit 0
fi

#scp -P 443 -i /home/drop/.ssh/drop-d1 $1 kv@ACSGSpace:/home/kv/Drops
scp -P 443 -i /home/drop/.ssh/$k $1 kv@ACSGSpace:/home/kv/Drops