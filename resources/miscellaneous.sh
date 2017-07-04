#!/bin/bash

# to make these functions available in your terminal, source this file.
# `. miscellaneous.sh`

# renames all files in directory, removing prefix defined by $remove
rename_files () {
  # public.access.csv -> access.csv
  remove=public.

  for filename in  "$remove"*
  do
    mv "$filename" "${filename#"$remove"}"
  done
}

copy_dir_from_pod_to_local () {
  # copies /tmp directory in pod to ./sql on local machine
  kubectl cp postgres-0:tmp sql -n vcs
}

copy_dir_from_local_to_pod () {
  # copies ./sql on local machine to /sql in pod
  kubectl cp sql vcs/postgres-0:sql
}

# any images pushed to the registry will be available to the cluster
launch_docker_registry_in_minikube_cluster () {
  eval $(minikube docker-env) && \
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
}

# usage `build_and_push_image imagename:latest ./path/to/dockerfile_dir`
build_and_push_image () {
  docker build -t "localhost:5000/$1" "$2" && \
  docker push "localhost:5000/$1"
}

watch_cluster () {
  while :
  do
    kubectl get svc,rc,po,deploy,statefulset,secrets,configmaps --all-namespaces
    kubectl get pv
    sleep 5
  done
}

# change `gogs` database password for `gogs` user
change_gogs_password () {
  kubectl exec postgres-0 -n vcs -- bash -c \
    "psql -U gogs -d gogs -c \"ALTER USER gogs WITH ENCRYPTED PASSWORD 'new_password'\""
}

create_sql_files_config_map () {
  kubectl create configmap sql-files --from-file=sql
}

seed_database_once_running () {
  not_ready=true

  while $not_ready
  do
    [[ $(kubectl get po -n vcs -o template --template '{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}' | grep postgres-0 | cut -f2 -d' ') == "Running" ]] && not_ready=false
    sleep 10
  done

  echo "Seeding database..."
  kubectl exec postgres-0 -n vcs -- sh -c 'cp -f /seed-script/seed /usr/bin/seed-script && chmod a+x /usr/bin/seed-script && seed-script'
}

port_forward_to_drone_when_running () {
  not_ready=true

  while $not_ready
  do
    [[ $(kubectl get po -n cicd -o template --template '{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}' | grep drone-server-0 | cut -f2 -d' ') == "Running" ]] && not_ready=false
    sleep 10
  done

  echo "Forwarding local port 1337 to drone server..."
  echo "Open http://localhost:1337 in your browser to view drone server web UI."
  kubectl port-forward drone-server-0 -n cicd 8000:8000
}

go_l33t_mode () {
  minikube start && sleep 300 && kubectl apply -f "${GOGS_REPO}/k8s/" && seed_database_once_running && kubectl apply -f "${DRONE_REPO}/k8s/" && port_forward_to_drone_when_running
}
