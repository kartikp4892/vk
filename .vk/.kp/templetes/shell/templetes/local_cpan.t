#!/bin/bash

set -e
set -xu

export PERL5LIB=$HOME/perl_modules/lib/:$HOME/perl_modules/lib/perl5/:

module_tar=$1
module_dir=${module_tar%.tar.gz}

if [[ "${module_tar}" != "${module_dir}" ]] ; then
  tar -xvf "${module_tar}"
  rm "${module_tar}"
fi

cd ${module_dir}
perl Makefile.PL PREFIX=$HOME/perl_modules \
                 INSTALLSCRIPT=$HOME/perl_modules/bin \
                 INSTALLBIN=$HOME/perl_modules/bin \
                 INSTALLMAN1DIR=$HOME/perl_modules/man/man1 \
                 INSTALLSITELIB=$HOME/perl_modules/lib

make
make test
make install
