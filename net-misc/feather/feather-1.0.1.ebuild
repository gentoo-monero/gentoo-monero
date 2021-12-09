# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A free, open-source Monero wallet"
HOMEPAGE="https://featherwallet.org"
SRC_URI="https://featherwallet.org/files/releases/linux/${PN}-${PV}-linux.zip -> ${P}.zip"

# Feather is released under the terms of the BSD license, but it vendors
# code from Monero and Tor too.
LICENSE="BSD MIT"
SLOT="0"
KEYWORDS=""
IUSE="xmrig +xmrto"

DEPEND="
	dev-libs/boost:=[nls,threads]
	dev-libs/libgcrypt:=
	dev-libs/libsodium:=
	dev-libs/monero-seed
	dev-libs/openssl:=
	>=dev-qt/qtcore-5.15
	>=dev-qt/qtgui-5.15
	>=dev-qt/qtnetwork-5.15
	>=dev-qt/qtsvg-5.15
	>=dev-qt/qtwebsockets-5.15
	>=dev-qt/qtwidgets-5.15
	>=dev-qt/qtxml-5.15
	media-gfx/qrencode:=
	net-dns/unbound:=[threads]
	net-libs/czmq:=
"
RDEPEND="
	${DEPEND}
	net-vpn/tor
"
BDEPEND="virtual/pkgconfig"

src_configure() {
	true
}

src_unpack() {
	default
	mv feather-${PV} feather
	mkdir ${P}
	mv feather ${P}/
}

src_compile() {
	true
}

src_install() {
	dobin "feather"
}

pkg_postinst() {
	true
}
