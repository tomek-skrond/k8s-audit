#!/bin/bash
set -o errexit
set -o nounset
set -eou pipefail

##################### CHAPTER 3 CONFIG #####################
LOGFILE="worker_node_conf"

PROJECT="k8s-audit" #here project id probably
SSH_KEY_PATH="/home/tomo/.ssh/id_rsa.pub"
CLUSTER="cluster-1"
##################### CHAPTER 3 CONFIG #####################

echo "Ensuring node connectivity"
# add ssh key to compute instances from cluster
gcloud compute os-login ssh-keys add \
	--key-file="${SSH_KEY_PATH}" \
	--project="${PROJECT}" \
	--ttl="10m" 1>/dev/null

echo "Getting IP of cluster nodes"
# get IPs of nodes
IPS=$(gcloud compute instances list --filter="${CLUSTER}" | awk '{if (NR!=1) print $5}')

echo "Creating log file"
# create log file
dir_name=$(dirname "$(realpath "$0")")
echo -n "" > ${dir_name}/${LOGFILE}.log

function get_kubeproxy_config() {
	# GET KUBEPROXY CONFIG PATH
	for ip in ${IPS[@]}; do
		output=$(ssh -oStrictHostKeyChecking=no $ip "ps -ef | grep kube-proxy")
		kubeproxy_conf=$(echo $output | grep -Eo --color '\-\-kubeconfig=((\/[A-Za-z\.\_\-]+)+)' | sed 's/--kubeconfig=//g')
		kubeproxy_conf=$(echo ${kubeproxy_conf} | tr -d ' ')
		echo "Kube-proxy config path for node ${ip} is: ${kubeproxy_conf}"
	done
	echo ""
}


function 3_1_1() {
	echo "3_1_1 Ensure that the proxy kubeconfig file permissions are set to 644 or more restrictive (Manual)"
	echo "3_1_1" >> ${LOGFILE}.log
	for ip in ${IPS[@]}; do
		# TEST PERMISSIONS
		rwx=$(ssh -oStrictHostKeyChecking=no $ip "stat -c %a '${kubeproxy_conf}'")

		if [[ "$rwx" -lt 644 || "$rwx" == "644" ]];then
			echo "$ip,PASSED"
			echo "$ip,PASS" >> ${LOGFILE}.log
		else
			echo "$ip,FAIL" >> ${LOGFILE}.log
		fi
	done
	echo ""
}

function 3_1_2() {
	echo "3_1_2 Ensure that the proxy kubeconfig file ownership is set to root:root (Manual)"
	echo "3_1_2" >> ${LOGFILE}.log
	for ip in ${IPS[@]}; do
		# TEST OWNERSHIP
		ownership=$(ssh -oStrictHostKeyChecking=no $ip "stat -c %U:%G '${kubeproxy_conf}'")
		
		if [[ "$ownership" == "root:root" ]];then
			echo "$ip,PASSED"
			echo "$ip,PASS" >> ${LOGFILE}.log
		else
			echo "$ip,FAIL" >> ${LOGFILE}.log
		fi
	done
	echo ""
}

function get_kubelet_config() {
	# GET KUBEPROXY CONFIG PATH
	for ip in ${IPS[@]}; do
		output=$(ssh -oStrictHostKeyChecking=no $ip "ps -ef | grep kubelet")
		kubelet_conf=$(echo $output | grep -Eo --color '\-\-config\s((\/[A-Za-z\.\_\-]+)+)' 2>/dev/null | sed 's/\-\-config\ //g')
		kubelet_conf=$(echo ${kubelet_conf} | tr -d ' ')
		echo "Kubelet config path for node ${ip} is: ${kubelet_conf}"
	done
	echo ""
}
function 3_1_3() {
	echo "3_1_3 Ensure that the kubelet configuration file has permissions set to 600 (Manual)"
	echo "3_1_3" >> ${LOGFILE}.log
	for ip in ${IPS[@]}; do
		# TEST PERMISSIONS
		rwx=$(ssh -oStrictHostKeyChecking=no $ip "stat -c %a '${kubelet_conf}'")

		if [[ "$rwx" == "600" ]];then
			echo "$ip,PASSED"
			echo "$ip,PASS" >> ${LOGFILE}.log
		else
			echo "$ip,FAIL" >> ${LOGFILE}.log
		fi
	done
	echo ""
}

function 3_1_4() {
	echo "3_1_4 Ensure that the kubelet configuration file ownership is set to root:root (Manual)"
	echo "3_1_4" >> ${LOGFILE}.log
	for ip in ${IPS[@]}; do
		# TEST OWNERSHIP
		ownership=$(ssh -oStrictHostKeyChecking=no $ip "stat -c %U:%G '${kubelet_conf}'")
		
		if [[ "$ownership" == "root:root" ]];then
			echo "$ip,PASSED"
			echo "$ip,PASS" >> ${LOGFILE}.log
		else
			echo "$ip,FAIL" >> ${LOGFILE}.log
		fi
	done
	echo ""
}

# Chapter 3 - Check Worker Node Config
#KUBEPROXY
get_kubeproxy_config
3_1_1
3_1_2
#KUBELET
get_kubelet_config
3_1_3
3_1_4