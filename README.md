# Docker as a Server

Running Docker container as a server which resides in the same network as other network devices.

The advantage of this is that these docker containers can appear as if they are a separate hosts on the network and each can listen on the same port numbers:

```md
Dev-Server  port 443
Test-Server port 443
```

## Requirements
- Promiscious mode on Host machine

## Turn-on Promiscious mode on Host
```bash
ifconfig -a
wlp1s0: flags=4419<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.35  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 2604:3d09:347b:f3e0::7e88  prefixlen 128  scopeid 0x0<global>
        inet6 2604:3d09:347b:f3e0:99c:efa8:280a:a346  prefixlen 64  scopeid 0x0<global>
        inet6 2604:3d09:347b:f3e0:99ca:4af3:adcd:461e  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::bc9:a111:dc5c:168d  prefixlen 64  scopeid 0x20<link>
        ether 64:cc:2e:88:3d:24  txqueuelen 1000  (Ethernet)
        RX packets 13070  bytes 6157993 (6.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 16279  bytes 2778498 (2.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# Turn on promiscious mode on interface (PROMISC)
sudo /usr/sbin/ip link set dev wlp1s0 promisc on
wlp1s0: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        inet 10.0.0.35  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 2604:3d09:347b:f3e0::7e88  prefixlen 128  scopeid 0x0<global>
        inet6 2604:3d09:347b:f3e0:99c:efa8:280a:a346  prefixlen 64  scopeid 0x0<global>
        inet6 2604:3d09:347b:f3e0:99ca:4af3:adcd:461e  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::bc9:a111:dc5c:168d  prefixlen 64  scopeid 0x20<link>
        ether 64:cc:2e:88:3d:24  txqueuelen 1000  (Ethernet)
        RX packets 13070  bytes 6157993 (6.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 16279  bytes 2778498 (2.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

## Permanently have promiscious mode enabled
```bash
cp bridge-promisc.service /etc/systemd/system
sudo systemctl enable bridge-promisc
```

## Create a Docker Network on the same network as the Host network
```bash
docker network create -d ipvlan \
  --subnet=10.0.0.0/24 \
  --gateway=10.0.0.1 \
  -o parent=wlp1s0 \
  db_net
```


## Build the Ubuntu image and run
```bash
docker build --no-cache -t ubuntu-ssh .
docker run --net=db_net --name ubuntu-ssh --ip 10.0.0.4 -d -p 22:22 ubuntu-ssh:latest
```

## SSH to login
```bash
ssh bwoo@10.0.0.4
bwoo@10.0.0.4's password: 
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-31-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

bwoo@718e0f485671:~$ 
```

