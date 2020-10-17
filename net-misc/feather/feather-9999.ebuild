# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="A free, open-source Monero wallet"
HOMEPAGE="https://featherwallet.org"
SRC_URI=""
EGIT_REPO_URI="https://git.wownero.com/feather/feather.git"

# Feather is released under the terms of the BSD license, but it vendors
# code from Monero and Tor too.
LICENSE="BSD MIT"
SLOT="0"
KEYWORDS=""
IUSE="libressl xmrig +xmrto"

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
RDEPEND="
	${DEPEND}
	net-vpn/tor
"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DARCH=x86_64
		-DBUILD_64=ON
		-DBUILD_SHARED_LIBS=Off # Vendored Monero libs collision
		-DBUILD_TAG="linux-x64"
		-DBUILD_TESTS=OFF
		-DBUILD_TOR=OFF
		-DDONATE_BEG=OFF
		-DINSTALL_VENDORED_LIBUNBOUND=OFF
		-DMANUAL_SUBMODULES=1
		-DSTATIC=OFF
		-DUSE_DEVICE_TREZOR=OFF
		-DXMRTO=$(usex xmrto)
		-DXMRig=$(usex xmrig)
	)

	cmake_src_configure
}

src_compile() {
	cmake_build feather
}

src_install() {
	dobin "${BUILD_DIR}/bin/feather"
}

pkg_postinst() {
	einfo "Ensure that Tor is running with 'rc-service tor start' before"
	einfo "using Feather."
}
