
###################################################################
# Step 0: Enable OvS and delete previous created objects (if any) #
###################################################################
systemctl enable openvswitch-switch
systemctl start openvswitch-switch

ovs-vsctl del-br s1 2>/dev/null
ovs-vsctl del-br s2 2>/dev/null
ovs-vsctl del-br s3 2>/dev/null
ovs-vsctl del-br s4 2>/dev/null
ovs-vsctl del-br s5 2>/dev/null
ovs-vsctl del-br sr 2>/dev/null

ip link delete v-ns11
ip link delete v-ns12
ip link delete v-ns21
ip link delete v-ns31
ip link delete v-ns41
ip link delete v-ns51
ip link delete v-ns52
ip link delete v-r13-1
ip link delete v-r13-3
ip link delete v-r45-4
ip link delete v-r45-5
ip link delete v-s2s1
ip link delete v-kali
ip link delete v-r13-ext

ip -all netns delete

ovs-vsctl add-br s1
ovs-vsctl add-br s2
ovs-vsctl add-br s3
ovs-vsctl add-br s4
ovs-vsctl add-br s5
ovs-vsctl add-br sr


#######################################
# Step 2: Create network namespaces #
#######################################
ip netns add ns11
ip netns add ns12
ip netns add ns21
ip netns add ns31
ip netns add ns41
ip netns add ns51
ip netns add ns52
ip netns add r13
ip netns add r45


##########################################################
# Step 3: Create links to connect namespaces to switches #
##########################################################
ip link add veth11 type veth peer name v-ns11
ip link set veth11 netns ns11
ip netns exec ns11 ip link set veth11 up
ip link set v-ns11 up

ip link add veth12 type veth peer name v-ns12
ip link set veth12 netns ns12
ip netns exec ns12 ip link set veth12 up
ip link set v-ns12 up

ip link add veth21 type veth peer name v-ns21
ip link set veth21 netns ns21
ip netns exec ns21 ip link set veth21 up
ip link set v-ns21 up

ip link add veth31 type veth peer name v-ns31
ip link set veth31 netns ns31
ip netns exec ns31 ip link set veth31 up
ip link set v-ns31 up

ip link add veth41 type veth peer name v-ns41
ip link set veth41 netns ns41
ip netns exec ns41 ip link set veth41 up
ip link set v-ns41 up

ip link add veth51 type veth peer name v-ns51
ip link set veth51 netns ns51
ip netns exec ns51 ip link set veth51 up
ip link set v-ns51 up

ip link add veth52 type veth peer name v-ns52
ip link set veth52 netns ns52
ip netns exec ns52 ip link set veth52 up
ip link set v-ns52 up

ip link add veth1 type veth peer name v-r13-1
ip link add veth3 type veth peer name v-r13-3
ip link set veth1 netns r13
ip link set veth3 netns r13
ip netns exec r13 ip link set veth1 up
ip netns exec r13 ip link set veth3 up
ip link set v-r13-1 up
ip link set v-r13-3 up

ip link add veth4 type veth peer name v-r45-4
ip link add veth5 type veth peer name v-r45-5
ip link set veth4 netns r45
ip link set veth5 netns r45
ip netns exec r45 ip link set veth4 up
ip netns exec r45 ip link set veth5 up
ip link set v-r45-4 up
ip link set v-r45-5 up

ip link add vethR45 type veth peer name v-r13-sr
ip link set vethR45 netns r13
ip netns exec r13 ip link set vethR45 up
ip link set v-r13-sr up

ip link add vethR13 type veth peer name v-r45-sr
ip link set vethR13 netns r45
ip netns exec r45 ip link set vethR13 up
ip link set v-r45-sr up

##########################################
# Step 4: Connect namespaces to switches #
##########################################
ovs-vsctl add-port s1 v-ns11
ovs-vsctl add-port s1 v-ns12
ovs-vsctl add-port s2 v-ns21
ovs-vsctl add-port s3 v-ns31
ovs-vsctl add-port s4 v-ns41
ovs-vsctl add-port s5 v-ns51
ovs-vsctl add-port s5 v-ns52
ovs-vsctl add-port s1 v-r13-1
ovs-vsctl add-port s3 v-r13-3
ovs-vsctl add-port s4 v-r45-4
ovs-vsctl add-port s5 v-r45-5
ovs-vsctl add-port sr v-r13-sr
ovs-vsctl add-port sr v-r45-sr


######################################
# Step 5: Connect switches s1 and s2 #
######################################
ip link add v-s1s2 type veth peer name v-s2s1
ip link set v-s1s2 up
ip link set v-s2s1 up
ovs-vsctl add-port s1 v-s1s2
ovs-vsctl add-port s2 v-s2s1


###############################################
# Step 6: Create external interface on router #
###############################################
ip link add veth-ext type veth peer name v-r13-ext
ip link set veth-ext netns r13
ip netns exec r13 ip link set veth-ext up
ip link set v-r13-ext up


######################################################
# Step 7: Connect Kali Linux host to virtual network #
######################################################
ip link add veth0 type veth peer name v-kali
ip link set veth0 up
ip link set v-kali up
ovs-vsctl add-port s2 v-kali


######################################################
# Step 8: Configure IP addresses and default gateway #
######################################################
ip netns exec ns11 ip addr add 10.0.0.11/24 dev veth11
ip netns exec ns11 ip route add default via 10.0.0.254
ip netns exec ns12 ip addr add 10.0.0.12/24 dev veth12
ip netns exec ns12 ip route add default via 10.0.0.254
ip netns exec ns21 ip addr add 10.0.0.21/24 dev veth21
ip netns exec ns21 ip route add default via 10.0.0.254
ip netns exec ns31 ip addr add 10.10.10.31/24 dev veth31
ip netns exec ns31 ip route add default via 10.10.10.254
ip netns exec ns41 ip addr add 10.20.20.41/24 dev veth41
ip netns exec ns41 ip route add default via 10.20.20.254
ip netns exec ns51 ip addr add 10.30.30.51/24 dev veth51
ip netns exec ns51 ip route add default via 10.30.30.254
ip netns exec ns52 ip addr add 10.30.30.52/24 dev veth52
ip netns exec ns52 ip route add default via 10.30.30.254

ip netns exec r13 ip addr add 10.0.0.254/24 dev veth1
ip netns exec r13 ip addr add 10.10.10.254/24 dev veth3
ip netns exec r13 ip addr add 192.168.100.13/24 dev veth-ext
ip netns exec r13 ip addr add 10.255.255.1/30 dev vethR45
ip netns exec r13 ip route add default via 192.168.100.254
ip netns exec r13 ip route add 10.20.20.0/24 via 10.255.255.2
ip netns exec r13 ip route add 10.30.30.0/24 via 10.255.255.2

ip netns exec r45 ip addr add 10.20.20.254/24 dev veth4
ip netns exec r45 ip addr add 10.30.30.254/24 dev veth5
ip netns exec r45 ip addr add 10.255.255.2/30 dev vethR13
ip netns exec r45 ip route add default via 10.255.255.1

ip addr add 10.0.0.200/24 dev veth0
ip route add 10.0.0.0/8 via 10.0.0.254

ip addr add 192.168.100.254/24 dev v-r13-ext

ip netns exec r13 sysctl -w net.ipv4.ip_forward=1
ip netns exec r13 iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -o veth-ext -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE