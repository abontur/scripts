
zones=(
    "us-east-1a"
    "us-east-1b"
    "us-east-1c"
    "us-east-1d"
    "us-east-1e"
    "us-east-1f"
)

service=$1
sum=0
for zone in "${zones[@]}"; do
    tmp=$(kubectl --as=admin \
        --as-group=system:masters \
        --context sell-dmz-staging\
        -n $service \
        -l topology.kubernetes.io/zone=${zone},role=http \
        get pods 2>/dev/null | tail -n +2 | wc -l)
    sum=$(( $sum+${tmp} ))
    echo "${zone} = ${tmp}" 
done

echo "Overall: $sum"

