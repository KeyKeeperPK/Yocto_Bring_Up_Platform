# Git Setup Commands

## After creating your repository on GitHub/GitLab/etc., run these commands:

```bash
# Add your remote repository (replace with your actual repository URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Or if using SSH:
# git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git

# Push the code to your repository
git push -u origin master

# Or if your default branch is 'main':
# git branch -M main
# git push -u origin main
```

## To clone this repository on another machine:

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME

# Initialize and update submodules (this will take several minutes)
git submodule update --init --recursive

# Set up the build environment for your target platform
./setup-build.sh [beaglebone|raspberrypi4|jetson-nano]

# Examples:
./setup-build.sh raspberrypi4    # For Raspberry Pi 4
./setup-build.sh jetson-nano     # For Jetson Nano
./setup-build.sh                 # For BeagleBone (default)

# Start building
bitbake core-image-minimal
```

## Manual Setup (Alternative):

```bash
# Choose your platform
PLATFORM=raspberrypi4

# Source Yocto environment
source poky/oe-init-build-env build-${PLATFORM}

# Restore platform configuration
cd ..
./restore-config.sh ${PLATFORM}
cd build-${PLATFORM}

# Build
bitbake core-image-minimal
```