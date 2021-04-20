# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Monero (XMR) Stratum protocol proxy"
HOMEPAGE="https://xmrig.com/proxy https://github.com/xmrig/xmrig-proxy"
SRC_URI="https://github.com/xmrig/xmrig-proxy/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ssl http"

DEPEND="
	dev-libs/libuv:=
	ssl? ( dev-libs/openssl:= )"

PATCHES=("${FILESDIR}/${PN}-5.10.2-nonotls.patch")

src_configure() {
	local mycmakeargs=(
		-DWITH_TLS=$(usex ssl)
		-DWITH_HTTP=$(usex http)
	)

	cmake_src_configure
}

src_install() {
	dodoc src/config.json
	dobin "${BUILD_DIR}/xmrig-proxy"
}
