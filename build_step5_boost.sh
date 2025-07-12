#!/bin/bash

echo "=== Step 5: Build Boost ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Load environment variables
cd thirdParty
source build_env.sh

echo "Building Boost with install path: ${INSTALL_PATH}"

# Download and extract Boost if needed
if [ ! -f "boost_1_80_0.tar.gz" ]; then
    echo "Downloading Boost 1.80.0..."
    wget https://sourceforge.net/projects/boost/files/boost/1.80.0/boost_1_80_0.tar.gz/download -O boost_1_80_0.tar.gz
fi

if [ ! -d "boost_1_80_0" ]; then
    echo "Extracting Boost..."
    tar -xzf boost_1_80_0.tar.gz
fi

cd boost_1_80_0

echo "Configuring Boost..."
./bootstrap.sh --with-libraries=python --prefix=${INSTALL_PATH} --with-python=${PYTHON_EXE}

if [ $? -eq 0 ]; then
    echo "Building Boost..."
    ./b2 install --with-python include=${PYTHON_INCLUDE} --prefix=${INSTALL_PATH}
    
    if [ $? -eq 0 ]; then
        echo "✅ Boost built and installed successfully!"
        echo "Boost installed to: ${INSTALL_PATH}"
        ls -la ${INSTALL_PATH}/lib/libboost_python39.so 2>/dev/null || ls -la ${INSTALL_PATH}/lib/libboost_python*.so
    else
        echo "❌ Boost build failed!"
        exit 1
    fi
else
    echo "❌ Boost configuration failed!"
    exit 1
fi
