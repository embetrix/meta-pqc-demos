FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit kernel-modsign

SRC_URI += "file://ima-evm.cfg \
            file://kmod-sign.cfg \
            file://crypto.cfg \
           "
