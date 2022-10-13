#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# progress=('-' '\' '|' '/' '-')

tmpDir=/tmp/sell-jsonnet-toolkit/
deployment_version_dir="$tmpDir"/deployments_versions
vendirs_paths="$tmpDir"/vendir_paths
rm -rf $tmpDir 2> /dev/null
[[ ! -e $tmpDir ]] && mkdir -p $tmpDir
[[ ! -e $deployment_version_dir ]] && mkdir -p $deployment_version_dir
[[ ! -e $vendirs_paths ]] && mkdir -p "$vendirs_paths"

function help() {
    echo This tool can be used to check version of sell-jsonnet-toolkit
}

function downloadFromGithub() {
    baseURL='https://raw.githubusercontent.com'
    service=$1
    filePath=$2
    fileName=$( echo "$filePath" | sed -nE 's|.*/(.*)$|\1|p')

    # echo curl -fH "Authorization: token $HOMEBREW_GITHUB_API_TOKEN" \
    #         -sSLJ "$baseURL"/"$service"/"$filePath" \
    #         --output "$vendirs_paths"/"${service#zendesk/}"
    curl -fH "Authorization: token $HOMEBREW_GITHUB_API_TOKEN" \
            -sSLJ "$baseURL"/"$service"/"$filePath" \
            --output "$vendirs_paths"/"${service#zendesk/}"
}

function extract_ver_from_deployment() {
    service=${1#zendesk/}
    kubectl \
        --as admin \
        --as-group system:masters \
        --context sell-dmz-staging \
        --namespace $service \
        describe deployment "$service" 2> /dev/null \
        | sed -nE "s|^Annotations.*sell_jsonnet_toolkit_version\": \"(.*)\"}|\1|p" \
        > "$deployment_version_dir/${service}" || return 0
}

if [ $# -gt 0 ]; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then help && exit 0; fi
    services=("$@")
else
    # Download latest service list from `sell-jsonnet-toolkit
    curl -fH "Authorization: token $HOMEBREW_GITHUB_API_TOKEN" \
            -sSLJ 'https://raw.githubusercontent.com/zendesk/sell-jsonnet-toolkit/main/.github/templates/sell-vendir-update.jsonnet' \
            --output "$vendirs_paths"/sell-jsonnet-toolkit

    services=($(sed -nE "s|.*{ repository: '(.*)'.*|\1|p" "$vendirs_paths"/sell-jsonnet-toolkit))
fi

echo 'Fetching files from repos and from deployments...'
for service in "${services[@]}"; do
    downloadFromGithub $service "master/vendir.yml" &
    extract_ver_from_deployment $service &
done

# echo 'Checking deployments versions ...'
# for service in "${services[@]}"; do
# done

# for i in {1..100000}; do
#     printf "\r${progress[$(( i % 4 ))]}"
# done
wait

FORMAT="%-45s %-25b %s\n"
printf "$FORMAT" "Service" "Repo Version" "Deployed Version"
# Iterate througth services list, download vendir.yml,
# parse it and show the current version of sell-jsonnet-toolkit
for service in "${services[@]}"; do

    ver=$(yq '.directories[].contents[].git.ref' "$vendirs_paths"/"${service#zendesk/}")
    deploy_ver=$(cat $deployment_version_dir/${service#zendesk/})
    deploy_ver=$([[ -z $deploy_ver ]] && echo "Not Found" || echo $deploy_ver)

    COLOR=$([[ $ver == $deploy_ver ]] && echo "\e[32m" || echo "\e[31m")
    printf "$FORMAT\e[0m" "$service" "$COLOR$ver" "$deploy_ver"

done
