#!/bin/bash

set -eou pipefail

packages_for_update=
if [ -n "$1" ] && command -v repoquery >/dev/null 2>&1; then
    installed_versions=$(rpm -qa --qf "%{NAME} = %{VERSION}-%{RELEASE}\n" | sort)
    available_versions=$(repoquery --quiet --provides --disablerepo='*' --enablerepo=$1 -a | sort)
    uptodate_versions=$(comm -12 <(printf "%s\n" "$installed_versions") <(printf "%s\n" "$available_versions"))


    installed=$(printf "%s\n" "$installed_versions" | cut -d= -f1 | sort)
    available=$(printf "%s\n" "$available_versions" | cut -d= -f1 | sort)
    uptodate=$(printf "%s\n" "$uptodate_versions" | cut -d= -f1 | sort)

    installed_for_update=$(comm -23 <(printf "%s\n" $installed) <(printf "%s\n" $uptodate))
    packages_for_update=$(comm -12 <(printf "%s\n" $installed_for_update) <(printf "%s\n" $available))
fi

if [ -z "$packages_for_update" ]; then
    echo "No packages were found for update..."
    exit
fi

PKG="$(command -v dnf || command -v yum)"
PKG_MGR="$(echo ${PKG:(-3)})"

if [ $PKG_MGR == "dnf" ]; then
    if ! echo $installed | grep -qw dnf-plugins-core; then
        $PKG install -y dnf-plugins-core
    fi
else
    if ! echo $installed | grep -qw yum-plugin-priorities; then
        $PKG install -y yum-plugin-priorities
    fi
fi
$PKG -y update $packages_for_update
rm -rf /var/cache/$PKG_MGR
