# k8s-ansible

Requirements :
- Ansible on the deployement node
- SSH key access on root account on targeted nodes

1) git clone https://github.com/Nyk0/k8s-ansible.git

2) cd k8s-ansible

3) adjust the hosts in inventory/hosts.yml

4) also adjust variables in inventory/hosts.yml

crio_version: "1.20"
-> Straightforward : CRIO version, tt binds the $VERSION parameter of the official documentation here : https://cri-o.io/ int the Ubuntu/Debian section

linux_version: Debian_10
-> Debian release version, it binds the $OS parameter of the official documentation here : https://cri-o.io/ int the Ubuntu/Debian section

debian_release: buster
-> This variable is used to append backports in sources.list to get the latest version of libseccomp2 required by CRIO

calico_version: v3.17
-> Straightforward : Calico version

kubernetes_version: "1.20.2-00"
-> Straightforward : Kubernetes version

4) ansible-playbook -i inventory/hosts.yml site.yml

Your cluster is ready, test :

5) go to api-server where kubectl has been configured
ssh api-server

6) run a test container :
root@api-server:~# kubectl -f debian1.yml apply
pod/debian1 created

7) Test connectivity with "Internet" :
root@api-server:~# kubectl exec -ti debian1 -- /bin/bash
root@debian1:/# ping www.google.fr
PING www.google.fr (216.58.214.67) 56(84) bytes of data.
64 bytes from par10s39-in-f3.1e100.net (216.58.214.67): icmp_seq=1 ttl=116 time=3.50 ms
64 bytes from par10s39-in-f3.1e100.net (216.58.214.67): icmp_seq=2 ttl=116 time=3.51 ms

8) Connectivity between pods :
root@api-server:~# kubectl -f debian2.yml apply
pod/debian2 created
root@api-server:~# kubectl get pods -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP                NODE    NOMINATED NODE   READINESS GATES
debian1   1/1     Running   0          3m30s   192.168.166.129   node1   <none>           <none>
debian2   1/1     Running   0          16s     192.168.104.1     node2   <none>           <none>
root@api-server:~# kubectl exec -ti debian1 -- /bin/bash
root@debian1:/# ping 192.168.104.1
PING 192.168.104.1 (192.168.104.1) 56(84) bytes of data.
64 bytes from 192.168.104.1: icmp_seq=1 ttl=62 time=0.334 ms
64 bytes from 192.168.104.1: icmp_seq=2 ttl=62 time=0.329 ms
