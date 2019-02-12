#!/bin/sh

set -eox pipefail

rpm -Uvh /tmp/*.rpm
rm -f /tmp/*.rpm
rm -f /tmp/rpm_install.sh
