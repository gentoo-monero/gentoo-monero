# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Proof of work algorithm based on random code execution"
HOMEPAGE="https://github.com/tevador/randomx"
SRC_URI="https://github.com/tevador/RandomX/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# librandomx itself is BSD-3, but it vendors blake2 (CC0).
LICENSE="BSD CC0-1.0"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=( "${FILESDIR}"/${PN}-1.1.9-noexecstack.patch )

S="${WORKDIR}/RandomX-${PV}"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=YES
	)

	cmake_src_configure
}

src_install() {
	dolib.so "${BUILD_DIR}"/librandomx.so
	dobin "${BUILD_DIR}"/randomx-{benchmark,codegen}
}

src_test() {
	"${BUILD_DIR}"/randomx-tests || die "tests failed"
}
