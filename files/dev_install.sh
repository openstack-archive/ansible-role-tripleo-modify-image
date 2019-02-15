set -e

# Cherry-pick a refspec
# $1 : project name e.g. keystone
# $2 : Gerrit refspec(s) to cherry pick
function cherrypick {
    local PROJ_NAME=$1
    local REFSPECS="$2"

    # check that git is installed
    if ! rpm -qi git &> /dev/null; then
        echo "Please install git before using this module."
        exit 1
    fi

    if [ ! -d "$PROJ_NAME" ]; then
        git clone "https://git.openstack.org/openstack/$PROJ_NAME"
    fi
    cd "$PROJ_NAME"
    for REFSPEC in $REFSPECS; do
        git fetch "https://review.openstack.org/openstack/$PROJ_NAME" "$REFSPEC"
        git cherry-pick FETCH_HEAD || git cherry-pick --abort
    done

    SKIP_GENERATE_AUTHORS=1 SKIP_WRITE_GIT_CHANGELOG=1 python setup.py sdist
    cp dist/*.tar.gz ../

}

mkdir -p refspec_projects
cd refspec_projects
cherrypick $1 $2
