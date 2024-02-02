found=$(kubectl get deployment -n prod | grep deployment1)
if [[ -z $found && -f {{ task_setup_yaml_path }} ]]; then
  kubectl apply -f {{ task_setup_yaml_path }}
  echo "Setup completed!"
fi
