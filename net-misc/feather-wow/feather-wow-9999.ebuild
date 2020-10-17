# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="A free, open-source Wownero wallet"
HOMEPAGE="https://featherwallet.org"
SRC_URI=""
EGIT_REPO_URI="https://git.wownero.com/feather/feather-wow.git"

# Feather is released under the terms of the BSD license, but it vendors
# code from Wownero and Tor too.
LICENSE="BSD MIT"
SLOT="0"
KEYWORDS=""
IUSE="libressl"

DEPEND="
	dev-libs/boost:=[nls,threads]
	dev-libs/libgcrypt:=
	dev-libs/libsodium:=
	dev-libs/monero-seed
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
	!libressl? ( dev-libs/openssl:= )
	libressl? ( dev-libs/libressl:= )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DARCH=x86_64
		-DBUILD_64=On
		-DBUILD_SHARED_LIBS=Off # Vendored Monero libs collision
		-DBUILD_TAG="linux-x64"
		-DBUILD_TESTS=Off
		-DBUILD_TOR=Off
		-DDONATE_BEG=Off
		-DINSTALL_VENDORED_LIBUNBOUND=Off
		-DMANUAL_SUBMODULES=1
		-DSTATIC=Off
		-DUSE_DEVICE_TREZOR=OFF
		-DXMRTO=Off
	)

	cmake_src_configure
}

src_compile() {
	cmake_build feather-wow
}

src_install() {
	dobin "${BUILD_DIR}/bin/feather-wow"
}
