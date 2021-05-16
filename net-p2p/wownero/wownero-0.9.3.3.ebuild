# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake systemd

MY_MINIUPNP_REV="4c700e09526a7d546394e85628c57e9490feefa0"
MY_RANDOMWOW_REV="89b7c02bba9100f5ed60056b1e7a82b742af56ce"
MY_SUPERCOP_REV="633500ad8c8759995049ccd022107d1fa8a1bbc9"

DESCRIPTION="Privacy-centric meme currency"
HOMEPAGE="https://www.wownero.org https://git.wownero.com/wownero/wownero"
SRC_URI="
	https://git.wownero.com/wownero/wownero/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://git.wownero.com/wownero/miniupnp/archive/${MY_MINIUPNP_REV}.tar.gz -> ${PN}-miniupnp-${MY_MINIUPNP_REV}.tar.gz
	https://git.wownero.com/wownero/RandomWOW/archive/${MY_RANDOMWOW_REV}.tar.gz -> ${PN}-randomwow-${MY_RANDOMWOW_REV}.tar.gz
	https://git.wownero.com/wownero/supercop/archive/${MY_SUPERCOP_REV}.tar.gz -> ${PN}-supercop-${MY_SUPERCOP_REV}.tar.gz
"
S="${WORKDIR}/${PN}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon readline tools +wallet-cli +wallet-rpc"
REQUIRED_USE="|| ( daemon tools wallet-cli wallet-rpc )"

RESTRICT="test"

DEPEND="
	dev-libs/boost:0/1.75.0[nls,threads]
	dev-libs/libsodium:=
	dev-libs/openssl:=
	dev-libs/rapidjson
	net-dns/unbound:=[threads]
	net-libs/czmq:=
	readline? ( sys-libs/readline:0= )"
RDEPEND="
	${DEPEND}
	acct-group/wownero
	acct-user/wownero"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-0.9.2.2-no-git.patch"
)

src_unpack() {
	default
	rmdir "${S}"/external/{miniupnp,RandomWOW,supercop} || die
	mv "${WORKDIR}/miniupnp" "${S}/external/miniupnp" || die
	mv "${WORKDIR}/randomwow" "${S}/external/RandomWOW" || die
	mv "${WORKDIR}/supercop" "${S}/external/supercop" || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DEBUG_UTILITIES=ON
		-DBUILD_DOCUMENTATION=OFF
		# Monero's liblmdb conflicts with the system liblmdb :(
		-DBUILD_SHARED_LIBS=OFF
		-DMANUAL_SUBMODULES=ON
		-DWOWNERO_PARALLEL_LINK_JOBS=1
		# The user can decide for themselves if they want to use ccache.
		-DUSE_CCACHE=OFF
		-DUSE_DEVICE_TREZOR=OFF
	)

	cmake_src_configure
}

src_compile() {
	local targets=()
	use daemon && targets+=(daemon)
	use tools && targets+=(blockchain_{ancestry,blackball,db,depth,export,import,prune,prune_known_spent_data,stats,usage})
	use wallet-cli && targets+=(simplewallet)
	use wallet-rpc && targets+=(wallet_rpc_server)
	cmake_build ${targets[@]}
}

src_install() {
	# Install all binaries.
	find "${BUILD_DIR}/bin/" -type f -executable -print0 |
		while IFS= read -r -d '' line; do
			dobin "$line"
		done

	if use daemon; then
		dodoc utils/conf/wownerod.conf

		# /etc/wownero/wownerod.conf
		insinto /etc/wownero
		newins "${FILESDIR}/wownerod-0.9.2.2.wownerod.conf" wownerod.conf

		# OpenRC
		newconfd "${FILESDIR}/wownerod-0.9.2.2.confd" wownerod
		newinitd "${FILESDIR}/wownerod-0.9.2.2.initd" wownerod

		# systemd
		systemd_newunit "${FILESDIR}/wownerod-0.9.2.2.service" wownerod.service
	fi
}

pkg_postinst() {
	if use daemon; then
		einfo "Start the Monero P2P daemon as a system service with"
		einfo "'rc-service wownerod start'. Enable it at startup with"
		einfo "'rc-update add wownerod default'."
		einfo
		einfo "systemd users can use 'systemctl start wownerod'"
		einfo
		einfo "Run wownerod status as any user to get sync status and other stats."
	fi
}
