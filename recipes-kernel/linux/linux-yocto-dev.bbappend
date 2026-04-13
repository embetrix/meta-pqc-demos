FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit kernel-modsign

SRC_URI += " \
            file://kmod-sign.cfg \
            file://crypto.cfg \
           "
