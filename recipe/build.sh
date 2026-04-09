#!/bin/bash

set -euxo pipefail

# this package only officially supports x86_64 on linux & osx at the moment
if [[ "${target_platform}" == "linux-64" ]] || [[ "${target_platform}" == osx-*  ]]; then

  # # we don't set this yet in the activation script, so ask rust? - we don't build with this yet.
  # export CARGO_BUILD_TARGET=$(rustc -vV | grep host | sed 's/host: //')

  pushd tensorboard/data/server
  cargo build --release

  pushd pip_package
  # Upstream defaults to manylinux_2_31 (Ubuntu 20.04). Conda's linux sysroot uses
  # glibc 2.28, so pip rejects that wheel tag during install ("not a supported wheel").
  if [[ "${target_platform}" == linux-* ]]; then
    $PYTHON build.py --out-dir="$SRC_DIR/" --server-binary=../target/release/rustboard --platform manylinux_2_28
  else
    $PYTHON build.py --out-dir="$SRC_DIR/" --server-binary=../target/release/rustboard
  fi

  $PYTHON -m pip install --no-deps --no-build-isolation --ignore-installed -v $SRC_DIR/*.whl

else

  pushd tensorboard/data/server/pip_package
  ${PYTHON} build.py --universal --out-dir="${SRC_DIR}/"
  ${PYTHON} -m pip install --no-deps --no-build-isolation --ignore-installed -v ${SRC_DIR}/*.whl

fi
