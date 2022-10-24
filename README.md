# Zenkub
Zenkub is a simple wraper for kubctl which holds some configuration

Pipes also work

ex: 

    zenkub <servicename: e.g.: 'sell-larva'> <any command accepted by kubectl: e.g.: get pods>

    zenkub sell-larva get deployments | grep some-name | cut -f 1 -w | xargs zenkub sell-larva delete deployment
