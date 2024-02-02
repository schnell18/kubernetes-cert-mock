found=$(kubectl get deployment -n prod-db | grep mysql)
if [[ -z $found && -f {{ task_setup_yaml_path }} ]]; then
  kubectl apply -f {{ task_setup_yaml_path }}
  echo "Setup completed!"
fi
