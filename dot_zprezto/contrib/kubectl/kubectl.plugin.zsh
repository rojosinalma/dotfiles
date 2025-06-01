# if (( $+commands[kubectl] )); then
#     __KUBECTL_COMPLETION_FILE="${ZSH_CACHE_DIR}/kubectl_completion"

#     if [[ ! -f $__KUBECTL_COMPLETION_FILE || ! -s $__KUBECTL_COMPLETION_FILE ]]; then
#         kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
#     fi

#     [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

#     unset __KUBECTL_COMPLETION_FILE
# fi

# Seal util script
alias ks='seal'

# This command is used a LOT both below and in daily life
alias k=kubectl

# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply a YML file
alias kaf='kubectl apply -f'
alias kak='kubectl apply -k' # For kustomize

# Replace stuff
alias krf='kubectl replace -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti $1 -- '

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'
alias kdelk='kubectl delete -k'

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'

# Service management.
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'

# Set context
kcn() {
  kubectl config set-context "$(kubectl config current-context)" --namespace="$1"
  export K8S_NAMESPACE="$1"
}

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias krr='kubectl rollout restart'
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f --timestamps'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

# Pretty logs
alias klp=' _klog_pretty'
alias klpf=' _klog_pretty -f'
alias klp1h=' _klog_pretty --since 1h'
alias klp1m=' _klog_pretty --since 1m'
alias klp1s=' _klog_pretty --since 1s'
alias klpf1h=' _klog_pretty --since 1h -f'
alias klpf1m=' _klog_pretty --since 1m -f'
alias klpf1s=' _klog_pretty --since 1s -f'


# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# PVC management.
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# Service account management.
alias kgsa="kubectl get sa"
alias kdsa="kubectl describe sa"
alias kdelsa="kubectl delete sa"

# DaemonSet management.
alias kgds='kubectl get daemonset'
alias kgdsw='kgds --watch'
alias keds='kubectl edit daemonset'
alias kdds='kubectl describe daemonset'
alias kdelds='kubectl delete daemonset'

# CronJob management.
alias kgcj='kubectl get cronjob'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'


# Only run if the user actually has kubectl installed
if (( ${+_comps[kubectl]} )); then
  kj() { kubectl "$@" -o json | jq; }
  kjx() { kubectl "$@" -o json | fx; }
  ky() { kubectl "$@" -o yaml | yh; }

  compdef kj=kubectl
  compdef kjx=kubectl
  compdef ky=kubectl
fi

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
