#!/bin/bash

echo "=== Step 3: Build OpenCV ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Load environment variables
cd thirdParty
source build_env.sh

echo "Building OpenCV with install path: ${INSTALL_PATH}"

# Download and extract OpenCV if needed
if [ ! -f "4.2.0.zip" ]; then
    echo "Downloading OpenCV 4.2.0..."
    wget https://github.com/opencv/opencv/archive/4.2.0.zip
fi

if [ ! -d "opencv-4.2.0" ]; then
    echo "Extracting OpenCV..."
    unzip -o 4.2.0.zip
fi

# Download and extract OpenCV contrib for CUDA support
if [ ! -f "opencv_contrib-4.2.0.zip" ]; then
    echo "Downloading OpenCV contrib 4.2.0..."
    wget https://github.com/opencv/opencv_contrib/archive/4.2.0.zip -O opencv_contrib-4.2.0.zip
fi

if [ ! -d "opencv_contrib-4.2.0" ]; then
    echo "Extracting OpenCV contrib..."
    unzip -o opencv_contrib-4.2.0.zip
fi

cd opencv-4.2.0
mkdir -p build && cd build

echo "Configuring OpenCV with CUDA support and contrib modules..."
cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} \
         -DCMAKE_BUILD_TYPE=Release \
         -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.2.0/modules \
         -DBUILD_TESTS=OFF \
         -DBUILD_PERF_TESTS=OFF \
         -DBUILD_EXAMPLES=OFF \
         -DBUILD_opencv_apps=OFF \
         -DBUILD_DOCS=OFF \
         -DWITH_CUDA=ON \
         -DCUDA_FAST_MATH=ON \
         -DWITH_CUBLAS=ON \
         -DWITH_CUFFT=ON \
         -DCUDA_ARCH_BIN="7.5 8.6" \
         -DWITH_OPENGL=OFF \
         -DWITH_QT=OFF \
         -DWITH_GTK=OFF \
         -DBUILD_opencv_python2=OFF \
         -DBUILD_opencv_python3=OFF

echo "Building OpenCV (this may take a while)..."
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Installing OpenCV..."
    make install
    
    if [ $? -eq 0 ]; then
        echo "✅ OpenCV built and installed successfully!"
        echo "OpenCV installed to: ${INSTALL_PATH}"
        ls -la ${INSTALL_PATH}/lib/cmake/opencv4/
    else
        echo "❌ OpenCV installation failed!"
        exit 1
    fi
else
    echo "❌ OpenCV build failed!"
    exit 1
fi
