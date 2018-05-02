#!/usr/bin/env python

import json
import subprocess
import sys

host_packages = json.load(sys.stdin)
rpm_output = subprocess.check_output(
    ['rpm', '-qa', '--qf', '%{NAME} %{VERSION}-%{RELEASE}\n']).split('\n')

image_packages = dict(i.split(' ') for i in rpm_output if i)

for pkg, version in image_packages.items():
    host_version = host_packages.get(pkg)
    if host_version and version != host_version:
        print('%s-%s does not match host version %s' % (
            pkg, version, host_version))
        sys.exit(1)

print('No package version differences found')
