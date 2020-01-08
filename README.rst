TripleO Modify Image
====================

A role to allow modification to container images built for the TripleO project.

Role Variables
--------------

.. list-table:: Variables used for modify image
   :widths: auto
   :header-rows: 1

   * - Name
     - Default Value
     - Description
   * - `source_image`
     - `[undefined]`
     - Mandatory fully qualified reference to the source image to be modified. The supplied Dockerfile will be copied and modified to make the FROM directive match this variable.
   * - `modify_dir_path`
     - `[undefined]`
     - Mandatory path to the directory containing the Dockerfile to modify the image
   * - `modified_append_tag`
     - `date +-modified-%Y%m%d%H%M%S`
     - String to be appended after the tag to indicate this is a modified version of the source image.
   * - `target_image`
     - `[undefined]`
     - If set, the modified image will be tagged with `target_image + modified_append_tag`. If `target_image` is not set, the modified image will be tagged with `source_image + modified_append_tag`. If the purpose of the image is not changing, it may be enough to rely on the `source_image + modified_append_tag` tag to identify that this is a modified version of the source image.
   * - `container_build_tool`
     - `docker`
     - Tool used to build containers, can be 'docker' or 'buildah'

.. list-table:: Variables used for yum update
   :widths: auto
   :header-rows: 1

   * - Name
     - Default Value
     - Description
   * - `source_image`
     - `[undefined]`
     - See modify image variables
   * - `modified_append_tag`
     - `date +-modified-%Y%m%d%H%M%S`
     - See modify image variables
   * - `target_image`
     - `''`
     - See modify image variables
   * - `rpms_path`
     - `''`
     - If set, packages present in rpms_path will be updated but dependencies must also be included if required as yum
       is called with localupdate.
   * - `update_repo`
     - `''`
     - If set, packages from this repo will be updated. Other repos will only be used for dependencies of these updates.
   * - `yum_repos_dir_path`
     - `None`
     - Optional path of directory to be used as `/etc/yum.repos.d` during the update
   * - `container_build_tool`
     - `docker`
     - See modify image variables
   * - `yum_cache`
     - `None`
     - Optional path to the host directory for yum cache during the update.
       Requires an overlay-enabled FS that also supports SE context relabling.
       Works only with container_build_tool=buildah.
   * - `force_purge_yum_cache`
     - `False`
     - Optional argument that tells buildah to forcefully re-populate the yum
       cache with new contents.

.. list-table:: Variables used for yum install
   :widths: auto
   :header-rows: 1

   * - Name
     - Default Value
     - Description
   * - `source_image`
     - `[undefined]`
     - See modify image variables
   * - `modified_append_tag`
     - `date +-modified-%Y%m%d%H%M%S`
     - See modify image variables
   * - `target_image`
     - `''`
     - See modify image variables
   * - `yum_packages`
     - `[]`
     - Provide a list of packages to install via yum
   * - `yum_repos_dir_path`
     - `None`
     - Optional path of directory to be used as `/etc/yum.repos.d` during the update
   * - `container_build_tool`
     - `docker`
     - See modify image variables


.. list-table:: Variables used for dev install
   :widths: auto
   :header-rows: 1

   * - Name
     - Default Value
     - Description
   * - `source_image`
     - `[undefined]`
     - See modify image variables
   * - `modified_append_tag`
     - `date +-modified-%Y%m%d%H%M%S`
     - See modify image variables
   * - `target_image`
     - `''`
     - See modify image variables
   * - `container_build_tool`
     - `docker`
     - See modify image variables
   * - `refspecs`
     - `[]`
     - An array of project/refspec pairs that will be installed into the generated container. Currently only supports python source projects.
   * - `python_dir`
     - `[]`
     - Directory which contains a Python project ready to be installed with pip.


Requirements
------------

 - ansible >= 2.4
 - python >= 2.6
 - docker-py >= 1.7.0
 - Docker API >= 1.20

Dependencies
------------

None

Example Playbooks
-----------------

Modify Image
~~~~~~~~~~~~

The following playbook will produce a modified image with the tag
`:latest-modified-<timestamp>` based on the Dockerfile in the custom directory
`/path/to/example_modify_dir`.

.. code-block::

    - hosts: localhost
      tasks:
      - name: include ansible-role-tripleo-modify-image
        import_role:
          name: ansible-role-tripleo-modify-image
          tasks_from: modify_image.yml
        vars:
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          modify_dir_path: /path/to/example_modify_dir
          container_build_tool: docker # or buildah

The directory `example_modify_dir` contains the `Dockerfile` which will perform
the modification, for example:

.. code-block::

    # This will be replaced in the file Dockerfile.modified
    FROM centos-binary-nova-api

    # switch to root to install packages
    USER root

    # install packages
    RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
    RUN python /tmp/get-pip.py

    # switch the container back to the default user
    USER nova

Yum update
~~~~~~~~~~

The following playbook will produce a modified image with the tag
`:latest-updated` which will do a yum update using the host's /etc/yum.repos.d.
Only file repositories will be used (with baseurl=file://...).
In this playbook the tasks\_from is set as a variable instead of an
`import_role` parameter.

.. code-block::

    - hosts: localhost
      tasks:
      - name: include ansible-role-tripleo-modify-image
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: yum_update.yml
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          yum_repos_dir_path: /etc/yum.repos.d
          modified_append_tag: updated
          container_build_tool: buildah # or docker
          yum_cache: /tmp/containers-updater/yum_cache
          rpms_path: /home/stack/rpms

.. code-block::

    - hosts: localhost
      tasks:
      - name: include ansible-role-tripleo-modify-image
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: yum_update.yml
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          modified_append_tag: updated
          container_build_tool: docker # or buildah
          rpms_path: /home/stack/rpms/

Note, if you have a locally installed gating repo, you can add
``update_repo: gating-repo``. This may be the case for the consequent in-place
deployments, like those performed with the CI reproducer script.


Yum install
~~~~~~~~~~~

The following playbook will produce a modified image with the tag
`:latest-updated` which will do a yum install of the requested packages
using the host's /etc/yum.repos.d.  In this playbook the tasks\_from is set as
a variable instead of an `import_role` parameter.

.. code-block::

    - hosts: localhost
      tasks:
      - name: include ansible-role-tripleo-modify-image
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: yum_install.yml
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          yum_repos_dir_path: /etc/yum.repos.d
          yum_packages: ['foobar-nova-plugin', 'fizzbuzz-nova-plugin']
          container_build_tool: docker # or buildah

RPM install
~~~~~~~~~~~

The following playbook will produce a modified image with RPMs from the
specified rpms\_path on the local filesystem installed as a new layer
for the container. The new container tag is appened with the '-hotfix'
suffix. Useful for creating adhoc hotfix containers with local RPMs with no
network connectivity.

.. code-block::

    - hosts: localhost
      tasks:
      - name: include ansible-role-tripleo-modify-image
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: rpm_install.yml
          source_image: docker.io/tripleomaster/centos-binary-nova-api:latest
          rpms_path: /home/stack/rpms
          modified_append_tag: -hotfix

Dev install
~~~~~~~~~~~

The following playbook will produce a modified image with Python source
code installed via pip. To minimize dependencies within the container
we generate the sdist locally and then copy it into the resulting
container image as an sdist tarball to run pip install locally.

It can be used to pull a review from OpenDev Gerrit:

.. code-block::

    - hosts: localhost
      connection: local
      tasks:
      - name: dev install heat-api
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: dev_install.yml
          source_image: docker.io/tripleomaster/centos-binary-heat-api:current-tripleo
          refspecs:
            -
              project: heat
              refspec: refs/changes/12/1234/3
          modified_append_tag: -devel

or it can be used to build an image from a local Python directory:

.. code-block::

    - hosts: localhost
      connection: local
      tasks:
      - name: dev install heat-api
        import_role:
          name: ansible-role-tripleo-modify-image
        vars:
          tasks_from: dev_install.yml
          source_image: docker.io/tripleomaster/centos-binary-heat-api:current-tripleo
          modified_append_tag: -devel
          python_dir:
            - /home/joe/git/openstack/heat

License
-------

Apache 2.0
