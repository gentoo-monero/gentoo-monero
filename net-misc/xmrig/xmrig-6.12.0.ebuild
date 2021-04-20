# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake optfeature

DESCRIPTION="RandomX, CryptoNight, KawPow, AstroBWT, and Argon2 CPU/GPU miner"
HOMEPAGE="https://xmrig.com https://github.com/xmrig/xmrig"
SRC_URI="https://github.com/xmrig/xmrig/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="donate ssl"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )
"

PATCHES=(
	"${FILESDIR}/${PN}-5.11.2-nonotls.patch"
)

src_prepare() {
	use donate || eapply "${FILESDIR}/${PN}-6.3.3-nodonate.patch"

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_TLS=$(usex ssl)
		-DWITH_OPENCL=OFF
		-DWITH_CUDA=OFF
	)

	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/xmrig"
}

pkg_postinst() {
	optfeature "cpu specific tweaks" sys-apps/msr-tools
}
