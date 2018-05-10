#!/bin/sh

set -ex

if [ -f /tmp/host_packages.json ]; then
    if /tmp/compare-package-json.py < /tmp/host_packages.json ; then
        echo "Host package versions match, no update required"
        exit
    fi
fi
yum -y update
rm -rf /var/cache/yum
