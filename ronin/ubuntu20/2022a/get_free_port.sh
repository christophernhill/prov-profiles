#!/bin/bash
port_used() {
 local port="${1#*:}"
 local host=$((expr "${1}" : '\(.*\):' || echo "localhost") | awk 'END{print $NF}')
 nc -w 2 "${host}" "${port}" < /dev/null &> /dev/null
}
export -f port_used

# port_used 22

# shuf -i 0-65535 -n 1

find_port() {
 local host="${1:-localhost}"
 local port=$(shuf -i "${2:-2000}"-"${3:-65535}" -n 1)
 while port_used "${host}:${port}"; do
  port=$(shuf -i "${2:-2000}"-"${3:-65535}" -n 1)
 done
 echo "${port}"

}

export -f find_port

fp=`find_port localhost 2000 65535`

echo ${fp}
