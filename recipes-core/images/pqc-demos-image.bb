DESCRIPTION = "PQC Demos image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=1c76c4cc354acaac30ed4d5eefea7245"

inherit core-image

IMAGE_FEATURES:append = " ssh-server-openssh"

IMAGE_INSTALL += " \
	leancrypto \
	curl \
	openssl \
	attr \
	keyutils \
	ima-evm-keys \
	"
