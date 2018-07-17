#!/bin/sh

set -ex

rpm -Uvh /tmp/*.rpm
rm -f /tmp/*.rpm
rm -f /tmp/rpm_install.sh
