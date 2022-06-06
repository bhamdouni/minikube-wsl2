#!/bin/bash

timeout=30

dockerd_isrunning () {
  test "$(docker info --format '{{.ServerVersion}}' 2>/dev/null)" != ""
}

dockerd_start () {
	service docker start
	# Wait 30 sec for docker daemon to start
	echo -n "Waiting for docker daemon to start... "
	for seq in `seq 1 $timeout`; do
	  #echo -n "sequence $seq: is docker running? "
	  dockerd_isrunning && break
	  #echo "no"
	  sleep 1
	done
	#echo "yes"
	if [ "$seq" == "$timeout" ]; then
			echo "Timeout"
			exit 1
	else
		echo "OK"
	fi
}

minikube_isrunning () {
	test "$(su -w http_proxy,https_proxy,no_proxy - minikube -c 'minikube status --format=''{{.Host}},{{.Kubelet}},{{.APIServer}}''')" == "Running,Running,Running"
}


minikube_start () {
	su -w http_proxy,https_proxy,no_proxy - minikube -c "minikube start --driver=docker"
	su -w http_proxy,https_proxy,no_proxy - minikube -c "minikube dashboard --port=32080 --url" &
}

dockerd_isrunning || dockerd_start
minikube_isrunning || minikube_start
exec su -w http_proxy,https_proxy,no_proxy - minikube
