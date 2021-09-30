#!/bin/bash

set -euxo pipefail

# this package only officially supports x86_64 on linux & osx at the moment
if [[ "${target_platform}" == "linux-64" ]] || [[ "${target_platform}" == osx-*  ]]; then

  # # we don't set this yet in the activation script, so ask rust? - we don't build with this yet.
  # export CARGO_BUILD_TARGET=$(rustc -vV | grep host | sed 's/host: //')

  pushd tensorboard/data/server
  cargo build --release

  pushd pip_package
  $PYTHON build.py --out-dir="$SRC_DIR/" --server-binary=../target/release/rustboard

  if [[ "${target_platform}" == "osx-arm64" ]]; then
    WHEEL_NAME=$(ls $SRC_DIR/*.whl)
    NEW_WHEEL_NAME=${WHEEL_NAME/macosx_10_9_x86_64/macosx_11_0_arm64}
    mv $WHEEL_NAME ${NEW_WHEEL_NAME}
  fi

  $PYTHON -m pip install --no-deps --ignore-installed -v $SRC_DIR/*.whl

else

  pushd tensorboard/data/server/pip_package
  ${PYTHON} build.py --universal --out-dir="${SRC_DIR}/"
  ${PYTHON} -m pip install --no-deps --ignore-installed -v ${SRC_DIR}/*.whl

fi
