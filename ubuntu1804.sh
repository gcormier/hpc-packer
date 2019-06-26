#!/bin/bash

# EFA
wget https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz
tar -xf aws-efa-installer-latest.tar.gz
cd aws-efa-installer
sudo ./efa_installer.sh -y
#fi_info -p efa
cd


# Get stuff
sudo apt install git makedepf90 gfortran gcc libnuma-dev patch htop iptraf-ng nvidia-cuda-dev libcurl4-openssl-dev m4 zlib1g-dev libhdf5-dev autoconf


# Make OpenUCX
wget https://github.com/openucx/ucx/releases/download/v1.5.2/ucx-1.5.2.tar.gz
tar xzf ucx-1.5.2.tar.gz
cd ucx-1.5.2
./contrib/configure-release --prefix=/opt/ucx-1.5.2
make -j `nproc`
sudo make install
cd

# Make OpenMPI
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz
tar zxvf openmpi-4.0.1.tar.gz
cd openmpi-4.0.1
./configure --prefix=/opt/openmpi-4.0.1 --enable-static --with-ucx=/opt/ucx-1.5.2 --with-libfabric=/opt/amazon/efa
make clean > /dev/null &>/dev/null
make all -j `nproc`
sudo make install
cd

# Add to path for everyone
echo 'pathmunge /opt/openmpi-4.0.1/bin after' | sudo tee -a /etc/profile.d/openmpi.sh
sudo chmod +x /etc/profile.d/openmpi.sh

# AzCopy Install
wget --content-disposition https://aka.ms/downloadazcopy-v10-linux
tar zxvf azcopy_linux_amd64_*.tar.gz
sudo cp azcopy_linux_amd64*/azcopy /usr/local/bin/

# NetCDF
wget https://github.com/Unidata/netcdf-c/archive/v4.7.0.tar.gz
tar zxvf v4.7.0.tar.gz
cd netcdf-c-4.7.0
./configure --prefix=/opt/netcdf-4.7.0
make -j `nproc`
sudo make install
cd

echo 'pathmunge /opt/netcdf-4.7.0/bin after' | sudo tee -a /etc/profile.d/netcdf.sh
sudo chmod +x /etc/profile.d/netcdf.sh

# NetCDF-Fortran
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.5.tar.gz
tar zxvf netcdf-fortran-4.4.5.tar.gz
cd netcdf-fortran-4.4.5/
export NCDIR=/opt/netcdf-4.7.0
export LD_LIBRARY_PATH=${NCDIR}/lib:/opt/netcdf-fortran-4.4.5/lib:${LD_LIBRARY_PATH}
export CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib
./configure --prefix=/opt/netcdf-fortran-4.4.5 CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib
make -j `nproc`
sudo make install
cd

echo 'pathmunge /opt/netcdf-fortran-4.4.5/bin after' | sudo tee -a /etc/profile.d/netcdf-fortran.sh
sudo chmod +x /etc/profile.d/netcdf-fortran.sh
