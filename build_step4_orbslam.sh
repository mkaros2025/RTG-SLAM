#!/bin/bash

echo "=== Step 4: Build ORB-SLAM2 ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Load environment variables
cd thirdParty
source build_env.sh

echo "Building ORB-SLAM2 with install path: ${INSTALL_PATH}"

# Set OpenCV directory
opencv_dir=${INSTALL_PATH}/lib/cmake/opencv4

# Check if OpenCV is installed
if [ ! -d "${opencv_dir}" ]; then
    echo "❌ OpenCV not found at ${opencv_dir}"
    echo "Please run build_step3_opencv.sh first!"
    exit 1
fi

echo "OpenCV found at: ${opencv_dir}"

# Build ORB-SLAM2
cd ORB-SLAM2-PYBIND

echo "Building ORB-SLAM2..."
bash build.sh ${opencv_dir} ${INSTALL_PATH}

if [ $? -eq 0 ]; then
    echo "✅ ORB-SLAM2 built successfully!"
    echo "ORB-SLAM2 installed to: ${INSTALL_PATH}"
    ls -la ${INSTALL_PATH}/lib/libORB_SLAM2.so 2>/dev/null || echo "Note: libORB_SLAM2.so location may vary"
else
    echo "❌ ORB-SLAM2 build failed!"
    exit 1
fi
