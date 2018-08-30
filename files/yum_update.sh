#!/bin/sh

set -ex

if [ -f /tmp/host_packages.json ]; then
    if /tmp/compare-package-json.py < /tmp/host_packages.json ; then
        echo "Host package versions match, no update required"
        exit
    fi
fi

packages_for_update=
if [ -n "$1" ] && command -v repoquery >/dev/null 2>&1; then
    packages_for_update=("$(repoquery --disablerepo='*' --enablerepo=$1 --qf %{NAME} -a)")
fi

if [ -z $package_for_update ]; then
    echo "No packages were found for update..."
    exit
fi

yum install -y yum-plugin-priorities
yum -y update $packages_for_update
rm -rf /var/cache/yum
