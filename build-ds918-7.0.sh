#!/bin/bash

# prepare build tools
sudo apt-get update && sudo apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

root=`pwd`
mkdir ds918-7.0
mkdir output
cd ds918-7.0

# download redpill
git clone --depth=1 https://github.com/RedPill-TTG/redpill-lkm.git
git clone --depth=1 https://github.com/RedPill-TTG/redpill-load.git

# download syno toolkit
curl --location "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM7.0/ds.apollolake-7.0.dev.txz/download" --output ds.apollolake-7.0.dev.txz

mkdir apollolake
tar -C./apollolake/ -xf ds.apollolake-7.0.dev.txz usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build

# build redpill-lkm
cd redpill-lkm
make LINUX_SRC=../apollolake/usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build
read -a KVERS <<< "$(sudo modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# build redpill-load
cd redpill-load
cp ${root}/user_config.DS918+.json ./user_config.json
sudo ./build-loader.sh 'DS918+' '7.0-41890'
mv images/redpill-DS918+_7.0-41890*.img ${root}/output/
cd ${root}
