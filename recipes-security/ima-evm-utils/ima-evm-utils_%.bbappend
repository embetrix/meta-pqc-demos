FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Use alternative tree for mldsa support
SRC_URI = "git://github.com/stefanberger/ima-evm-utils.git;branch=mldsa;protocol=https \
           file://0001-evmctl-auto-promote-to-v3-signatures-for-ML-DSA-keys.patch \
          "
SRCREV = "32bdce92eb436da9ea5b3ba691ad50fd08f0d669"

PV = "1.5+git"
