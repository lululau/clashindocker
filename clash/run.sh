#! /bin/sh
sh -c ./config_iptables.sh
crond && ./clash -d . -f ./config.yml