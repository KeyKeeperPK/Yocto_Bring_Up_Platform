SUMMARY = "Custom Raspberry Pi 5 hardware interface initialization scripts"
DESCRIPTION = "Scripts to initialize and configure SSH, WiFi, Ethernet, Docker, CAN, CAN-FD, UART, and SPI on Raspberry Pi 5"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS:${PN} = "bash docker-moby wpa-supplicant can-utils"

PV = "1.0.0"
PR = "r0"

COMPATIBLE_MACHINE = "raspberrypi5"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/../rpi4-init-scripts/files:"

SRC_URI = " \
    file://rpi4-hardware-init.sh \
    file://rpi4-can-setup.sh \
    file://can.cfg \
    file://rpi4-uart-setup.sh \
    file://rpi4-spi-setup.sh \
    file://rpi4-hardware-init.tmpfiles \
    file://rpi5-hardware-init.service \
    file://rpi5-hardware-init.patch;apply=yes \
    file://rpi5-can-setup.patch;apply=yes \
    "

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "rpi5-hardware-init.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${systemd_unitdir}/system
    install -d ${D}${sysconfdir}/rpi5

    install -m 0755 ${WORKDIR}/rpi4-hardware-init.sh ${D}${bindir}/rpi5-hardware-init.sh
    install -m 0755 ${WORKDIR}/rpi4-can-setup.sh ${D}${bindir}/rpi5-can-setup.sh
    install -m 0755 ${WORKDIR}/rpi4-uart-setup.sh ${D}${bindir}/rpi5-uart-setup.sh
    install -m 0755 ${WORKDIR}/rpi4-spi-setup.sh ${D}${bindir}/rpi5-spi-setup.sh

    install -m 0644 ${WORKDIR}/rpi5-hardware-init.service ${D}${systemd_unitdir}/system/

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/rpi4-hardware-init.tmpfiles         ${D}${sysconfdir}/tmpfiles.d/rpi5-hardware-init.tmpfiles

    echo "Raspberry Pi 5 Industrial Configuration v${PV}-${PR}" > ${D}${sysconfdir}/rpi5/version
    echo "Features: SSH, WiFi, Docker, CAN-FD, UART, SPI, Ethernet, Pi5-specific service handling" >> ${D}${sysconfdir}/rpi5/version
}

FILES:${PN} += " \
    ${bindir}/rpi5-hardware-init.sh \
    ${bindir}/rpi5-can-setup.sh \
    ${bindir}/rpi5-uart-setup.sh \
    ${bindir}/rpi5-spi-setup.sh \
    ${systemd_unitdir}/system/rpi5-hardware-init.service \
    ${sysconfdir}/rpi5/version \
    ${sysconfdir}/tmpfiles.d/rpi5-hardware-init.tmpfiles \
    "

PROVIDES = "raspberrypi5-init-scripts"
RPROVIDES:${PN} = "raspberrypi5-init-scripts"
