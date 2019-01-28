#!/bin/bash

set -eux

packages_for_update=
if [ -n "$1" ] && command -v repoquery >/dev/null 2>&1; then
    installed=$(rpm -qa --qf "%{NAME}\n" | sort)
    available=$(repoquery --provides --disablerepo='*' --enablerepo=$1 --qf %{NAME} -a | cut -d= -f1 | sort)
    packages_for_update=$(comm -12 <(printf "%s\n" $installed) <(printf "%s\n" $available))
fi

if [ -z "$packages_for_update" ]; then
    echo "No packages were found for update..."
    exit
fi

yum install -y yum-plugin-priorities
yum -y update $packages_for_update
rm -rf /var/cache/yum
