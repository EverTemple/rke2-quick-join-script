# rke2-quick-join-script
Quickly join a server/agent into a RKE2 cluster.

## Usage
Download to your machine using curl. Update the variables accordingly.

```bash
curl -o- https://raw.githubusercontent.com/EverTemple/rke2-quick-join-script/master/join.sh | env T="$TOKEN" IP="$MASTER_NODE_IP" P="$MASTER_NODE_PORT" TYPE="$SERVER_TYPE" bash -x
```
