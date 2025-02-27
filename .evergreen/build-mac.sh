#!/bin/bash -ex

# Get access to testinstall.
. .evergreen/utils.sh

# Create temp directory for validated files.
rm -rf validdist
mkdir -p validdist
mv dist/* validdist || true

for VERSION in 3.6 3.7 3.8 3.9 3.10; do
    PYTHON=/Library/Frameworks/Python.framework/Versions/$VERSION/bin/python3
    rm -rf build

    # Install wheel if not already there.
    if ! $PYTHON -m wheel version; then
        createvirtualenv $PYTHON releasevenv
        WHEELPYTHON=python
        python -m pip install --upgrade wheel
    else
        WHEELPYTHON=$PYTHON
    fi

    $WHEELPYTHON setup.py bdist_wheel
    deactivate || true
    rm -rf releasevenv

    # Test that each wheel is installable.
    for release in dist/*; do
        testinstall $PYTHON $release
        mv $release validdist/
    done
done

mv validdist/* dist
rm -rf validdist
ls dist
