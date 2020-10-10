# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="Privacy-centric meme currency"
HOMEPAGE="https://www.wownero.org https://git.wownero.com/wownero/wownero"
SRC_URI=""
EGIT_REPO_URI="https://git.wownero.com/wownero/wownero.git"
EGIT_COMMIT="v${PV}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl readline"

DEPEND="
	dev-libs/boost:=[nls,threads]
	dev-libs/libsodium:=
	net-dns/unbound:=[threads]
	net-libs/czmq:=
	!libressl? ( dev-libs/openssl:= )
	libressl? ( dev-libs/libressl:= )
	readline? ( sys-libs/readline:0= )"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		# Monero's liblmdb conflicts with the system liblmdb :(
		-DBUILD_SHARED_LIBS=OFF
		-DMANUAL_SUBMODULES=ON
	)

	cmake_src_configure
}

src_install() {
	dodoc utils/conf/wownerod.conf

	find "${BUILD_DIR}/bin/" -type f -executable -print0 |
		while IFS= read -r -d '' line; do
			dobin "$line"
		done
}
