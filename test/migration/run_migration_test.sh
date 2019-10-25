#!/bin/bash

# Exit script if you try to use an uninitialized variable.
set -o nounset
# Exit script if a statement returns a non-true return value.
set -o errexit
# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
POD_NAME=system-migration

system_image() {
  oc get is amp-system-master -o=go-template='{{ .status.dockerImageRepository }}'
}

POD_IMAGE=$(system_image)
echo "IMAGE: ${POD_IMAGE}"

build_pod_spec() {
  ruby $DIR/build_testpod_template.rb ${POD_NAME} ${POD_IMAGE}
}

oc run ${POD_NAME} --rm -ti --image ${POD_IMAGE} --restart=Never --wait=true --overrides="$(build_pod_spec)"
