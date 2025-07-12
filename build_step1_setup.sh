#!/bin/bash

echo "=== Step 1: Environment Setup ==="

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate RTG-SLAM

# Create directories
mkdir -p thirdParty && cd thirdParty
install_path=$(pwd)/install
mkdir -p ${install_path}

# Get Python environment info
python_prefix=$(python -c "import sys; print(sys.prefix)")  
python_include=${python_prefix}/include/python3.9/
python_lib=${python_prefix}/lib/libpython3.9.so
python_exe=${python_prefix}/bin/python
python_env=${python_prefix}/lib/python3.9/site-packages/
numpy_include=$(python -c "import numpy; print(numpy.get_include())")  

echo "Install path: ${install_path}"
echo "Python prefix: ${python_prefix}"
echo "Python include: ${python_include}"
echo "Python lib: ${python_lib}"
echo "Python exe: ${python_exe}"
echo "Python env: ${python_env}"
echo "Numpy include: ${numpy_include}"

# Save environment variables to a file for other scripts
cat > build_env.sh << EOF
#!/bin/bash
export INSTALL_PATH="${install_path}"
export PYTHON_PREFIX="${python_prefix}"
export PYTHON_INCLUDE="${python_include}"
export PYTHON_LIB="${python_lib}"
export PYTHON_EXE="${python_exe}"
export PYTHON_ENV="${python_env}"
export NUMPY_INCLUDE="${numpy_include}"
EOF

echo "Environment setup complete! Variables saved to build_env.sh"
echo "You can now run the next steps."
