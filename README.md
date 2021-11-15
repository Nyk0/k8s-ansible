# k8s-ansible
### Requirements
- Ansible on the deployement (frontal) node, you find a virtualenv based instance in /root/ansible. You can use it by running :
```sh
root@frontal:~# source /root/ansible/bin/activate
```
- SSH key access on root account on targeted nodes

You can download ready to use OVA images  [here](https://drive.google.com/drive/folders/1w9PGi8DmTsLYmBFpYu7CAcfHnMeCP4Dl?usp=sharing). You will find 3 files, a frontal with Ansible on it (see deployment section), the node admin is the api-server and 2 nodes that act as workers.

### Deployement
To deploy Kubernetes on admin (api-server) and node[1-2] (Workers) follow these steps :
```sh
root@frontal:~# git clone https://github.com/Nyk0/k8s-ansible.git
root@frontal:~# cd k8s-ansible
```
Then, adjust the hosts and related variables in inventory/hosts.yml :

- crio_version: "1.22" => CRIO version, it binds the $VERSION parameter of the official documentation [here](https://cri-o.io/) in the Ubuntu/Debian section
- linux_version: Debian_11 => Debian release version, it binds the $OS parameter of the official documentation [here](https://cri-o.io/) in the Ubuntu/Debian section
- calico_version: v3.21 => Calico version
- kubernetes_version: "1.22.3-00" => Kubernetes version
```sh
root@frontal:~# ansible-playbook -i inventory/hosts.yml site.yml
```
### Test your installation
Your cluster is ready, you can ssh to admin node. This node is both api-server and frontend with kubectl enabled :
```sh
root@frontal:~# ssh admin
```
Run a test container :
```sh
root@admin:~# kubectl -f debian1.yml apply
pod/debian1 created
```
You can test connectivity with external world :
```sh
root@admin:~# kubectl exec -ti debian1 -- /bin/bash
root@debian1:/# ping www.google.fr
PING www.google.fr (216.58.214.67) 56(84) bytes of data.
64 bytes from par10s39-in-f3.1e100.net (216.58.214.67): icmp_seq=1 ttl=116 time=3.50 ms
64 bytes from par10s39-in-f3.1e100.net (216.58.214.67): icmp_seq=2 ttl=116 time=3.51 ms
```
And Connectivity between pods :
```sh
root@admin:~# kubectl -f debian2.yml apply
pod/debian2 created
root@admin:~# kubectl get pods -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP                NODE    NOMINATED NODE   READINESS GATES
debian1   1/1     Running   0          3m30s   192.168.166.129   node1   <none>           <none>
debian2   1/1     Running   0          16s     192.168.104.1     node2   <none>           <none>
root@admin:~# kubectl exec -ti debian1 -- /bin/bash
root@debian1:/# ping 192.168.104.1
PING 192.168.104.1 (192.168.104.1) 56(84) bytes of data.
64 bytes from 192.168.104.1: icmp_seq=1 ttl=62 time=0.334 ms
64 bytes from 192.168.104.1: icmp_seq=2 ttl=62 time=0.329 ms
```
