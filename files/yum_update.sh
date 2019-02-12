#!/bin/bash

set -eoux pipefail

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

PKG="$(command -v dnf || command -v yum)"
PKG_MGR="$(echo ${PKG:(-3)})"

if [ $PKG_MGR == "dnf" ]; then
    $PKG install -y dnf-plugins-core
else:
    $PKG install -y yum-plugin-priorities
fi
$PKG -y update $packages_for_update
rm -rf /var/cache/$PKG_MGR
