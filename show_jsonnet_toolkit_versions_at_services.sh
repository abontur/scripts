#!/bin/sh

services=(

    'zendesk/sell-activity_tracker'
    'zendesk/sell-appointments'
    'zendesk/sell-apps-integrations'
    'zendesk/sell-assigner'
    'zendesk/sell-automator'
    'zendesk/sell-bft-worker'
    'zendesk/sell-bft-operator'
    'zendesk/sell-bookings-1g'
    'zendesk/sell-bus'
    'zendesk/sell-calendars-integrator'
    'zendesk/sell-caliper'
    'zendesk/sell-capture-forms'
    'zendesk/sell-close-data-hub'
    'zendesk/sell-collaborations'
    'zendesk/sell-common'
    'zendesk/sell-cosmic-proxy'
    'zendesk/sell-crm'
    'zendesk/sell-crowd'
    'zendesk/sell-custom-fields'
    'zendesk/sell-datadog-daemonset'
    'zendesk/sell-dinero'
    'zendesk/sell-duplo'
    'zendesk/sell-elasticproxy'
    'zendesk/sell-engage'
    'zendesk/sell-escleaner'
    'zendesk/sell-external-orders'
    'zendesk/sell-eye'
    'zendesk/sell-fastlinks'
    'zendesk/sell-feeder-2g'
    'zendesk/sell-firehose-api'
    'zendesk/sell-firehose-doctor'
    'zendesk/sell-firehose-factoid'
    'zendesk/sell-firehose-monitor'
    'zendesk/sell-firehose-replicator'
    'zendesk/sell-frontend-entry'
    'zendesk/sell-g_service'
    'zendesk/sell-gatekeeper'
    'zendesk/sell-geoproxy'
    'zendesk/sell-glonass'
    'zendesk/sell-goals'
    'zendesk/sell-google-calendar-adapter'
    'zendesk/sell-importer'
    'zendesk/sell-indexing-auditor'
    'zendesk/sell-integrations-sync'
    'zendesk/sell-jarvaboot'
    'zendesk/sell-larva'
    'zendesk/sell-layouts'
    'zendesk/sell-leads'
    'zendesk/sell-linkr'
    'zendesk/sell-mailman'
    'zendesk/sell-mentions'
    'zendesk/sell-messenger'
    'zendesk/sell-notificatus'
    'zendesk/sell-oauth2-connector'
    'zendesk/sell-payments'
    'zendesk/sell-permissions'
    'zendesk/sell-product-goals'
    'zendesk/sell-pusher'
    'zendesk/sell-rabbit-hole'
    'zendesk/sell-rabbitqos'
    'zendesk/sell-reach'
    'zendesk/sell-recurring-revenue'
    'zendesk/sell-sales'
    'zendesk/sell-sancho'
    'zendesk/sell-scores'
    'zendesk/sell-seeker'
    'zendesk/sell-servus'
    'zendesk/sell-sleipnir'
    'zendesk/sell-smart-attributes'
    'zendesk/sell-smart-lists'
    'zendesk/sell-stencil'
    'zendesk/sell-tags'
    'zendesk/sell-telegram'
    'zendesk/sell-texter'
    'zendesk/sell-triggers'
    'zendesk/sell-truth'
    'zendesk/sell-uploader'
    'zendesk/sell-user_settings'
    'zendesk/sell-usuvator'
    'zendesk/sell-validator'
    'zendesk/sell-vector-daemonset'
    'zendesk/sell-views'
    'zendesk/sell-visits'
    'zendesk/sell-voice'
    'zendesk/sell-cosmic-sync'
    'zendesk/sell-imap-watcher'
)
echo "| Service | Version |" > ver_per_service.md
echo "|---|---|" >> ver_per_service.md
element=0
for service in "${services[@]}"; do
    curl -H "Authorization: token $HOMEBREW_GITHUB_API_TOKEN"\
        -sLJO https://raw.githubusercontent.com/$service/master/vendir.yml
    ver=$(yq '.directories[].contents[].git.ref' vendir.yml)
    echo "| $service | $ver |" >> ver_per_service.md
    rm vendir.yml
    elements=${#services[@]}
    element=$(( $element + 1 ))
    printf 'Fetching files from repos: '$(($element * 100 / $elements))"%%\r"
done

glow ver_per_service.md

