#!/bin/bash

template_file=./app.tmpl.ini

cat > ../k8s/01-gogs-ini-tmpl-configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: gogs-ini-tmpl
  namespace: vcs
data:
  app.tmpl.ini: |
    $(cat ${template_file})
EOF
