# TripleO Modify Image #

A role to allow modification to container images built for the TripleO project.

## Role Variables ##

**Variables used for modify image**

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `source_image` | `[undefined]` | Mandatory fully qualified reference to the source image to be modified. The supplied Dockerfile will be copied and modified to make the FROM directive match this variable. |
| `modify_dir_path` | `[undefined]` | Mandatory path to the directory containing the Dockerfile to modify the image |
| `modified_append_tag` | `date +-modified-%Y%m%d%H%M%S` | String to be appended after the tag to indicate this is a modified version of the source image. |
| `modified_image_prefix` | `''` | If set, the modified image will be tagged with this reference. If the purpose of the image is not changing, it may be enough to rely on `modified_append_tag` to identify that this is a modified version of the source image. `modified_append_tag` will still be appended to this reference. |

**Variables used for yum update**

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `source_image` | `[undefined]` | See modify image variables |
| `modified_append_tag` | `date +-modified-%Y%m%d%H%M%S` | See modify image variables |
| `modified_image_prefix` | `''` | See modify image variables |
| `yum_repos_dir_path` | `None` | Optional path of directory to be used as `/etc/yum.repos.d` during the update |
| `compare_host_packages` | `False` | If `True`, skip yum update when package versions match host package versions |

## Requirements ##

 - ansible >= 2.4
 - python >= 2.6
 - docker-py >= 1.7.0
 - Docker API >= 1.20

## Dependencies ##

None

## Example Playbooks ##

### Modify Image ###

The following playbook will produce a modified image with the tag
`:latest-modified-<timestamp>` based on the Dockerfile in the custom directory
`/path/to/example_modify_dir`.

    - hosts: localhost
      tasks:
      - name: include tripleo-modify-image
        import_role:
          name: tripleo-modify-image
          tasks_from: modify_image.yml
        vars:
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          modify_dir_path: /path/to/example_modify_dir

The directory `example_modify_dir` contains the `Dockerfile` which will perform
the modification, for example:

    # This will be replaced in the file Dockerfile.modified
    FROM centos-binary-nova-api

    # switch to root to install packages
    USER root

    # install packages
    RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
    RUN python /tmp/get-pip.py

    # switch the container back to the default user
    USER nova

### Yum update ###

The following playbook will produce a modified image with the tag
`:latest-updated` which will do a yum update using the host's /etc/yum.repos.d.
The yum update will only occur if there are differences between host and image
package versions. In this playbook the tasks_from is set as a variable instead
of an `import_role` parameter.

    - hosts: localhost
      tasks:
      - name: include tripleo-modify-image
        import_role:
          name: tripleo-modify-image
        vars:
          tasks_from: yum_update.yml
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          compare_host_packages: true
          yum_repos_dir_path: /etc/yum.repos.d
          modified_append_tag: updated

## License ##

Apache 2.0
