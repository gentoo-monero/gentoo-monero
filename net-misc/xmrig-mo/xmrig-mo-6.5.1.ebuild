# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MO_PV="mo1"
DESCRIPTION="RandomX, CryptoNight, KawPow, AstroBWT and Argon2 miner for the MoneroOcean pool"
HOMEPAGE="https://xmrig.com https://moneroocean.stream/ https://github.com/MoneroOcean/xmrig"
SRC_URI="https://github.com/MoneroOcean/xmrig/archive/v${PV}-${MO_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="donate +ssl"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )
"

S="${WORKDIR}/xmrig-${PV}-${MO_PV}"

PATCHES=("${FILESDIR}/${PN}-nonotls.patch")

src_prepare() {
	use donate || PATCHES+=("${FILESDIR}/${PN}-no-default-donate.patch")
	cmake_src_prepare
}

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
	newbin "${BUILD_DIR}/xmrig" "xmrig-mo"
}

pkg_postinst() {
	einfo "Install sys-apps/msr-tools and load the msr kernel module so that"
	einfo "XMRig can perform CPU specific tweaks like disabling the instruction"
	einfo "prefetcher. Also remember to increase the vm.nr_hugepages sysctl"
	einfo "value so that XMRig can allocate with huge pages."
	einfo ""
	einfo "XMRig-MoneroOcean has been installed as /usr/bin/xmrig-mo"
	einfo "in order to differentiate between the original XMRig"
}
