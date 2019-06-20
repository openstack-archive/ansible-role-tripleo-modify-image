#!/bin/bash

set -eou pipefail

PKG="$(command -v dnf || command -v yum)"
PKG_MGR="$(echo ${PKG:(-3)})"

if [ $PKG_MGR == "dnf" ]; then
    REPOQUERY_CMD="$PKG repoquery"
else
    REPOQUERY_CMD="$(command -v repoquery)"
fi

packages_for_update=
if [ -n "$1" ] && [[ -n $REPOQUERY_CMD ]]; then
    installed_versions=$(rpm -qa --qf "%{NAME} = %{VERSION}-%{RELEASE}\n" | sort)
    # dnf repoquery return 1 when repo does not exists, but standalone does not
    available_versions=$($REPOQUERY_CMD --quiet --provides --disablerepo='*' --enablerepo=$1 -a | sort || true)
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


if [ $PKG_MGR == "dnf" ]; then
    plugin=dnf-plugins-core
else
    plugin=yum-plugin-priorities
fi

if $(! echo $installed | grep -qw $plugin) && $($PKG list available $plugin >/dev/null 2>&1); then
    $PKG install -y $plugin
fi

$PKG -y update $packages_for_update
rm -rf /var/cache/$PKG_MGR
