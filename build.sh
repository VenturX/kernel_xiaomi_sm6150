#!/bin/bash
#
# Compile script for kernel

SECONDS=0

ZIPNAME="Vantom-KSUNext-$(date '+%Y%m%d-%H%M').zip"

export ARCH=arm64
export KBUILD_BUILD_USER=$(whoami)
export KBUILD_BUILD_HOST=archlinux
export PATH="$HOME/toolchains/clang-r547379/bin/:$HOME/toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/:$HOME/toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"

if [[ $1 = "-c" || $1 = "--clean" ]]; then
    rm -rf out
    echo "Cleaned output folder"
fi

echo -e "\nStarting compilation for sweet...\n"
make O=out ARCH=arm64  sweet_defconfig
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    CC="clang" \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-none-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-none-linux-gnueabihf-

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

if [[ ! -f "$kernel" || ! -f "$dtbo" || ! -f "$dtb" ]]; then
    echo -e "\nCompilation failed!"
    exit 1
fi

echo -e "\nKernel compiled successfully! Zipping up...\n"

if [ ! -d "AnyKernel3" ]; then
    echo "AnyKernel3 directory not found. Cloning from GitHub..."
    if ! git clone -q https://github.com/basamaryan/AnyKernel3 -b master AnyKernel3; then
        echo -e "\nFailed to clone AnyKernel3 from GitHub! Aborting..."
        exit 1
    fi
else
    echo "AnyKernel3 directory found."
fi

cp $kernel AnyKernel3
cp $dtbo AnyKernel3
cp $dtb AnyKernel3
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git
cd ..

echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"
