#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/download.sh"
source "${SCRIPT_DIR}/lib/checkout_from_repo.sh"

log "Step 0: Activating conda base env..."
# Conda is provided by condacolab in Colab; ensure we’re in base
source /usr/local/etc/profile.d/conda.sh
conda activate base
python -V
python -m pip --version

log "Step 1: Installing Python packages using Conda and Pip..."
yaml_file="${SCRIPT_DIR}/basic_colab_env.yaml"
if conda env update --name base --file "${yaml_file}" --prune; then
  log "Python packages installed successfully."
else
  error "Failed to install Python packages."
  exit 1
fi

log "Step 2: Cloning data repositories..."
goestd_repo="https://github.com/phenix-project/geostd.git"
get_repo "$goestd_repo" "geostd"

# temporarily check out prody from repo for numpy 2 compatibility
prody_repo="https://github.com/prody/ProDy.git"
get_repo "$prody_repo" "prody"
cd prody
python -m pip install .
cd ..

log "Step 3: Downloading executables..."
download_autodock_gpu "1.6"

log "Colab environment setup completed successfully!"

log "Additional: Installing Meeko with drop-in version fix..."
git clone https://github.com/forlilab/Meeko.git
sed -i "s/, *<3\.12//" Meeko/setup.py
python -m pip install -v --use-pep517 --no-cache-dir ./Meeko
