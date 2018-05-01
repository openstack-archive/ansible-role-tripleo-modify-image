# TripleO Modify Image #

A role to allow modification to container images built for the TripleO project.

## Role Variables ##

**Variables used for modifying an image**

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `source_image` | `None` | Mandatory fully qualified reference to the source image to be modified. The supplied Dockerfile will be copied and modified to make the FROM directive match this variable. |
| `modify_dir_path` | `None` | Mandatory path to the directory containing the Dockerfile to modify the image |
| `modified_append_tag` | `None` | String to be appended after the tag to indicate this is a modified version of the source image. Defaults to the output of the command `date +-modified-%Y%m%d%H%M%S` |
| `modified_image` | `{{ source_image }}` | If set, the modified image will be tagged with this reference. If the purpose of the image is not changing, it may be enough to rely on `modified_append_tag` to identify that this is a modified version of the source image. `modified_append_tag will still be appended to this reference. |

## Requirements ##

 - ansible >= 2.4
 - python >= 2.6
 - docker-py >= 1.7.0
 - Docker API >= 1.20

## Dependencies ##

None

## Example Playbooks ##

The following playbook will produce a modified image tagged with
`latest-modified-<timestamp>`

    - hosts: localhost
      tasks:
      - name: include tripleo-modify-image
        import_role:
          name: tripleo-modify-image
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


## License ##

Apache 2.0
