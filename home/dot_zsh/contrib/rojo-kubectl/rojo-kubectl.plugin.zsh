# Extras
alias krr='kubectl rollout restart'

# Seal util script
alias ks='seal'

# Kustomize
alias kak='kubectl apply -k'
alias kdelk='kubectl delete -k'

# Pretty logs
alias klp=' _klog_pretty'
alias klpf=' _klog_pretty -f'
alias klp1h=' _klog_pretty --since 1h'
alias klp1m=' _klog_pretty --since 1m'
alias klp1s=' _klog_pretty --since 1s'
alias klpf1h=' _klog_pretty --since 1h -f'
alias klpf1m=' _klog_pretty --since 1m -f'
alias klpf1s=' _klog_pretty --since 1s -f'

# --- Exec into Pods
# Finds any pod with the given name and tries to run exec inside of it
kexec() {
  local pod_base="$1"
  shift
  if [[ -z "$pod_base" ]]; then
    echo "❌ Usage: kexec <pod-name-prefix>"
    return 1
  fi

  # Search all namespaces for a pod that starts with the given name
  local line
  line=$(kubectl get pods --all-namespaces --no-headers -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name | grep "^.*[[:space:]]$pod_base" | head -n 1)

  if [[ -z "$line" ]]; then
    line=$(kubectl get pods --all-namespaces --no-headers -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name | grep "$pod_base" | head -n 1)
  fi

  if [[ -z "$line" ]]; then
    echo "❌ No pod found matching prefix '$pod_base' in any namespace"
    return 1
  fi

  local namespace pod_name
  namespace=$(echo "$line" | awk '{print $1}')
  pod_name=$(echo "$line" | awk '{print $2}')

  echo "✅ Found pod: $pod_name in namespace: $namespace"

  # Try available shells
  for shell in bash zsh sh ash; do
    echo "🔍 Trying shell: $shell"
    if kubectl exec -n "$namespace" -it "$pod_name" -- "$shell" -c "exit" &>/dev/null; then
      echo "🚀 Launching shell: $shell"
      kubectl exec -n "$namespace" -it "$pod_name" -- "$shell"
      return
    fi
  done

  echo "❌ No supported shell (bash, zsh, sh, ash) found in pod '$pod_name'"
  return 1
}

# Pretty-print kubectl logs timestamps: 2025-05-18T14:23:45.678Z → 18.05 14:23:45
_klog_pretty() {
  kubectl logs --timestamps "$@" | \
  awk '{
    ts = $1                                # full RFC-3339 stamp
    split(ts, a, "T")                      # a[1]=YYYY-MM-DD  a[2]=hh:mm:ss.fffZ
    split(a[1], d, "-")                    # d[1]=YYYY d[2]=MM d[3]=DD
    split(a[2], t, ":")                    # t[1]=HH t[2]=MM t[3]=SS(.fffZ)
    gsub(/[.Z].*/, "", t[3])               # keep only SS
    yy = substr(d[1], 3, 2)                # last two digits of year
    printf "%s.%s.%s %s:%s:%s - ", d[3], d[2], yy, t[1], t[2], t[3]
    $1 = ""                                # drop original stamp
    sub(/^ /, "")                          # trim leading space
    print                                  # emit the rest of the line
  }'
}
