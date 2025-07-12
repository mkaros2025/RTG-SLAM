#!/bin/bash

echo "=== Step 2: Build Pangolin ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Load environment variables
cd thirdParty
source build_env.sh

echo "Building Pangolin with install path: ${INSTALL_PATH}"

# Build pangolin
if [ ! -d "Pangolin" ]; then
    echo "Cloning Pangolin..."
    git clone -b v0.5 https://github.com/stevenlovegrove/Pangolin.git
else
    echo "Pangolin directory already exists, skipping clone."
fi

cd Pangolin
mkdir -p build && cd build

echo "Configuring Pangolin..."
cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH}

echo "Building Pangolin..."
make install -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ Pangolin built successfully!"
    echo "Pangolin installed to: ${INSTALL_PATH}"
    ls -la ${INSTALL_PATH}/lib/cmake/Pangolin/
else
    echo "❌ Pangolin build failed!"
    exit 1
fi
