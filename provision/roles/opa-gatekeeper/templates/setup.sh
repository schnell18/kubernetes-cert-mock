found=$(kubectl get crds | grep constrainttemplates.templates.gatekeeper.sh)
if [[ -z $found && -f {{ opa_gatekeeper_yaml_path }} ]]; then
  kubectl apply -f {{ opa_gatekeeper_yaml_path }}
  echo "Setup completed!"
fi
