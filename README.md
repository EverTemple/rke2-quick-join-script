# rke2-quick-join-script
Quickly update the packages, setup necessary packages, as well as join a server/agent node into a RKE2 cluster.

## Usage
Download to your machine using curl. Update the variables accordingly.

| Variable  | Value |
| --- | --- |
| T  | Master Server Join Token (`cat /var/lib/rancher/rke2/server/node-token` on <br /> the master server node to obtain the token) |
| IP  | Master Server IP |
| P  | Master Server Port (default: 9345) |
| TYPE  | Node type (server/agent) |

```bash
curl -o- https://raw.githubusercontent.com/EverTemple/rke2-quick-join-script/master/join.sh | env T="$TOKEN" IP="$MASTER_NODE_IP" P="$MASTER_NODE_PORT" TYPE="$SERVER_TYPE" bash -
```

## Disclaimer
Only tested it on Ubuntu 22.04.2 LTS. I use it for joining new servers myself, but I'm not responsible for any damage it may cause.