# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="RandomX, CryptoNight, AstroBWT and Argon2 CPU/GPU miner"
HOMEPAGE="https://xmrig.com https://github.com/xmrig/xmrig"
SRC_URI="https://github.com/xmrig/xmrig/archive/v6.2.0-beta.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/xmrig-6.2.0-beta"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ssl"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )"

PATCHES=("${FILESDIR}/${PN}-5.11.2-nonotls.patch")

src_configure() {
	local mycmakeargs=(
		# TODO: Create expanded USE flag for all of the PoW algos.

		-DWITH_TLS=$(usex ssl)

		# TODO: opencl USE flag.
		-DWITH_OPENCL=OFF

		# TODO: cuda USE flag.
		-DWITH_CUDA=OFF
	)

	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/xmrig"
}

pkg_postinst() {
	einfo "Install sys-apps/msr-tools and load the msr kernel module so that"
	einfo "XMRig can perform CPU specific tweaks like disabling the instruction"
	einfo "prefetcher. Also remember to increase the vm.nr_hugepages sysctl"
	einfo "value so that XMRig can allocate with huge pages."
}
