#!/bin/bash

seed_script=./restore-database.sh

cat > ../k8s/01-psql-seed-script-configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: psql-seed-script
  namespace: vcs
data:
  seed: |
    $(cat ${seed_script})
EOF
