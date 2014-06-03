PostgreDnaLoader
================


TODO:

- Improve the insertions with COPY or PREPARE.
- Improve the schema handling.
- Add a configuration file for db variables.

Install
=======
You'll need netCDF4 and HDF5 packages for NTCF format (amber trajectory).
Also you'll need to install MDAnalysis package (this is more or less obvious due to 
the explicit declaration in the code, but netCDF4 is not).

Reference = https://code.google.com/p/mdanalysis/wiki/netcdf

Packages needed:
- HDF5 library from ftp://ftp.hdfgroup.org/HDF5/current/src
- netcdf4 library from ftp://ftp.unidata.ucar.edu/pub/netcdf/
- https://github.com/Unidata/netcdf4-python

IMPORTANT:  Don't use the repo netcdf library.

Compiling on Ubuntu 10.04 Lucid Lynx
====================================

Download latest source for the HDF5 library from ftp://ftp.hdfgroup.org/HDF5/current/src

wget ftp://ftp.hdfgroup.org/HDF5/current/src/hdf5-1.8.9.tar.bz2
tar -jxvf hdf5-1.8.9.tar.bz2
cd hdf5-1.8.9

Install into /usr/local:
```
HDF5_DIR=/usr/local
./configure --prefix=$HDF5_DIR --enable-hl --enable-shared
make
sudo make install
```

Download latest source code for the netcdf4 library from ftp://ftp.unidata.ucar.edu/pub/netcdf/
```
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.2.0.tar.gz
cd netcdf-4.2
./configure --prefix=/usr/local --enable-netcdf-4 --enable-shared --enable-dap --disable-doxygen CPPFLAGS="-I$HDF5_DIR/include" LDFLAGS="-L$HDF5_DIR/lib"
make
sudo make install
```

This also installs into /usr/local.

After netcdf4 has been installed, MDAnalysis can be installed with python setup.py install and it will automatically install netcdf4-python in the process. 



