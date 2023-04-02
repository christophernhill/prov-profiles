#!/bin/bash
#
#
# Base spack setup
# 
#

source ./setup.sh

cat <<'EOF' | vagrant ssh
mkdir spack-2023-04
cd spack-2023-04
git clone https://github.com/spack/spack
mv spack spack-git
mkdir .spack
ln -s `pwd`/.spack ~/.spack
cd spack-git
. ./share/spack/setup-env.sh
spack compiler find
EOF

cat <<EOF > spack_externals.yaml
packages:
  pkgconf:
    externals:
    - spec: pkgconf@1.4.2
      prefix: /usr
  gawk:
    externals:
    - spec: gawk@4.2.1
      prefix: /usr
    buildable: false
  diffutils:
    externals:
    - spec: diffutils@3.6
      prefix: /usr
    buildable: false
  bison:
    externals:
    - spec: bison@3.0.4
      prefix: /usr
    buildable: false
  m4:
    externals:
    - spec: m4@1.4.18
      prefix: /usr
    buildable: false
  openssl:
    externals:
    - spec: openssl@1.1.1k
      prefix: /usr
    buildable: false
  libtool:
    externals:
    - spec: libtool@2.4.6
      prefix: /usr
    buildable: false
  automake:
    externals:
    - spec: automake@1.16.1
      prefix: /usr
    buildable: false
  autoconf:
    externals:
    - spec: autoconf@2.69
      prefix: /usr
    buildable: false
  texinfo:
    externals:
    - spec: texinfo@6.5
      prefix: /usr
    buildable: false
  cmake:
    externals:
    - spec: cmake@3.20.2
      prefix: /usr
    buildable: false
  gmake:
    externals:
    - spec: gmake@4.2.1
      prefix: /usr
    buildable: false
  gmp:
    externals:
    - spec: gmp@6.2.1
      prefix: /usr
    buildable: false
  zstd:
    externals:
    - spec: zstd@1.5.4
      prefix: /usr
    buildable: false
  mpfr:
    externals:
    - spec: mpfr@4.2.0
      prefix: /usr
    buildable: false
  zlib:
    externals:
    - spec: zlib@1.2.13
      prefix: /usr
    buildable: false
  mpc:
    externals:
    - spec: mpc@1.3.1
      prefix: /usr
    buildable: false


  gcc:
    compiler: [gcc@8.5.0]
EOF
vagrant scp spack_externals.yaml :.spack/packages.yaml

cat <<'EOF' > spack_modules.yam
modules:
  default:
    roots:
      lmod: /home/vagrant/modules/2023-04
      flat: True
    arch_folder: false
    lmod:
      hash_length: 0
      exclude_implicits: true
      core_compilers:
      - gcc@8.5.0
      - gcc@12.2.0
      projections:
            all: '{name}/{version}'
EOF
vagrant scp spack_modules.yaml :.spack/modules.yaml

cat <<EOF | vagrant ssh
cd spack-2023-04
cd spack-git
. ./share/spack/setup-env.sh
spack install gcc@12.2.0
spack module lmod refresh -y
module use share/spack/modules/linux-rocky8-sandybridge
mname=`module -t avail  2>&1 | grep '^gcc-12' `
module load $mname
spack compiler find
EOF






