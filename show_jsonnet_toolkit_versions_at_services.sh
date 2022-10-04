#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

tmpDir=/tmp/sell-jsonnet-toolkit/
deployment_version_dir="$tmpDir/deployments_versions"
[[ ! -e $tmpDir ]] && mkdir -p $tmpDir
[[ ! -e $deployment_version_dir ]] && mkdir -p $deployment_version_dir

function downloadFromGithub() {
    baseURL='https://raw.githubusercontent.com'
    service=$1
    filePath=$2
    fileName=$( echo "$filePath" | sed -nE 's|.*/(.*)$|\1|p')

    CODE=$(curl -fH "Authorization: token $HOMEBREW_GITHUB_API_TOKEN" \
            -sSLJ "$baseURL"/"$service"/"$filePath" \
            --output "$tmpDir"/"$fileName"
        )
    #echo "$CODE"
}

function extract_ver_from_deployment() {
    service=${1#zendesk/}
    service=${service/_/-}
    kubectl --as admin --as-group system:masters --context sell-dmz-staging --namespace $service describe deployment "$service" \
        | sed -nE "s|^Annotations.*sell_jsonnet_toolkit_version\": \"(.*)\"}|\1|p" \
        > "$deployment_version_dir/${1#zendesk/}"
}

# Download latest serwice list from `sell-jsonnet-toolkit
downloadFromGithub "zendesk/sell-jsonnet-toolkit" "main/.github/templates/sell-vendir-update.jsonnet" "sell-vendir-update.jsonnet"

services=($(sed -nE "s|.*{ repository: '(.*)'.*|\1|p" "$tmpDir"/sell-vendir-update.jsonnet))


echo "| Service | Repo Version | Deployed Version |" > "$tmpDir"/ver_per_service

for service in "${services[@]}"; do
    downloadFromGithub $service "master/vendir.yml" "${service#zendesk/}vendir.yml" &
    extract_ver_from_deployment $service &
done
echo 'Fetching files from repos ...'
wait
echo 'Checking deployments versions ...'
# Iterate througth services list, download vendir.yml,
# parse it and show the current version of sell-jsonnet-toolkit
for service in "${services[@]}"; do

    ver=$(yq '.directories[].contents[].git.ref' "$tmpDir"/"${service#zendesk/}"vendir.yml)
    echo "| $service | $ver | $(cat $deployment_version_dir/${service#zendesk/}) |" >> "$tmpDir"/ver_per_service

done

column -t -s "|" "$tmpDir"/ver_per_service

