#!/bin/bash

echo "=== Step 6: Build Python Bindings ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Load environment variables
cd thirdParty
source build_env.sh

echo "Building Python bindings with install path: ${INSTALL_PATH}"

# Check dependencies
opencv_dir=${INSTALL_PATH}/lib/cmake/opencv4
pangolin_dir=${INSTALL_PATH}/lib/cmake/Pangolin
boost_lib=${INSTALL_PATH}/lib/libboost_python39.so
orbslam_lib=${INSTALL_PATH}/lib/libORB_SLAM2.so

echo "Checking dependencies..."
echo "OpenCV: ${opencv_dir}"
echo "Pangolin: ${pangolin_dir}"
echo "Boost: ${boost_lib}"
echo "ORB-SLAM2: ${orbslam_lib}"

# Check if all dependencies exist
missing_deps=0
if [ ! -d "${opencv_dir}" ]; then
    echo "❌ OpenCV not found"
    missing_deps=1
fi
if [ ! -d "${pangolin_dir}" ]; then
    echo "❌ Pangolin not found"
    missing_deps=1
fi
if [ ! -f "${boost_lib}" ] && [ ! -f "${INSTALL_PATH}/lib/libboost_python3*.so" ]; then
    echo "❌ Boost Python library not found"
    missing_deps=1
fi
if [ ! -f "${orbslam_lib}" ]; then
    echo "❌ ORB-SLAM2 library not found"
    missing_deps=1
fi

if [ $missing_deps -eq 1 ]; then
    echo "❌ Missing dependencies. Please run previous build steps first!"
    exit 1
fi

# Build Python bindings
cd pybind
mkdir -p build && cd build

echo "Configuring Python bindings..."
cmake .. -DPYTHON_INCLUDE_DIRS=${PYTHON_INCLUDE} \
         -DPYTHON_LIBRARIES=${PYTHON_LIB} \
         -DPYTHON_EXECUTABLE=${PYTHON_EXE} \
         -DBoost_INCLUDE_DIRS=${INSTALL_PATH}/include \
         -DBoost_LIBRARIES=${boost_lib} \
         -DORB_SLAM2_INCLUDE_DIR=${INSTALL_PATH}/include/ORB_SLAM2 \
         -DORB_SLAM2_LIBRARIES=${orbslam_lib} \
         -DOpenCV_DIR=${opencv_dir} \
         -DPangolin_DIR=${pangolin_dir} \
         -DPYTHON_NUMPY_INCLUDE_DIR=${NUMPY_INCLUDE} \
         -DCMAKE_INSTALL_PREFIX=${PYTHON_ENV}

if [ $? -eq 0 ]; then
    echo "Building Python bindings..."
    make install -j$(nproc)
    
    if [ $? -eq 0 ]; then
        echo "✅ Python bindings built and installed successfully!"
        echo "Bindings installed to: ${PYTHON_ENV}"
    else
        echo "❌ Python bindings build failed!"
        exit 1
    fi
else
    echo "❌ Python bindings configuration failed!"
    exit 1
fi
