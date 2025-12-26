SUMMARY = "Custom Raspberry Pi 4 dhcpcd network manager configuration"
DESCRIPTION = "Scripts to config static Ethernet ip on Raspberry Pi 4"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "raspberrypi4-64"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://eth0-static.nmconnection \
    file://10-manage-all.conf \
    "

do_install() {
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/10-manage-all.conf \
        ${D}${sysconfdir}/NetworkManager/conf.d/
}

do_install:append() {
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0644 ${WORKDIR}/eth0-static.nmconnection \
        ${D}${sysconfdir}/NetworkManager/system-connections/
}

FILES:${PN} += " \
    ${sysconfdir}/NetworkManager/system-connections/eth0-static.nmconnection \
    ${sysconfdir}/NetworkManager/conf.d/10-manage-all.conf \
    "