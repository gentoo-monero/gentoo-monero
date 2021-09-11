# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

MY_MINIUPNP_REV="544e6fcc73c5ad9af48a8985c94f0f1d742ef2e0"
MY_RANDOMWOW_REV="62c6ea1176f6e3085a04e3c72b174c776b7981d9"
MY_SUPERCOP_REV="633500ad8c8759995049ccd022107d1fa8a1bbc9"

DESCRIPTION="Privacy-centric meme currency"
HOMEPAGE="https://www.wownero.org https://git.wownero.com/wownero/wownero"
SRC_URI="
	https://git.wownero.com/wownero/wownero/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/miniupnp/miniupnp/archive/${MY_MINIUPNP_REV}.tar.gz -> ${PN}-miniupnp-${PV}.tar.gz
	https://git.wownero.com/wownero/RandomWOW/archive/${MY_RANDOMWOW_REV}.tar.gz -> ${PN}-randomwow-${MY_RANDOMWOW_REV}.tar.gz
	https://github.com/monero-project/supercop/archive/${MY_SUPERCOP_REV}.tar.gz -> ${PN}-supercop-${PV}.tar.gz
"
S="${WORKDIR}/${PN}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon readline tools +wallet-cli +wallet-rpc"
REQUIRED_USE="|| ( daemon tools wallet-cli wallet-rpc )"

RESTRICT="test"

DEPEND="
	dev-libs/boost:=[nls,threads(+)]
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
	mv "${WORKDIR}/miniupnp-${MY_MINIUPNP_REV}" "${S}/external/miniupnp" || die
	mv "${WORKDIR}/randomwow" "${S}/external/RandomWOW" || die
	mv "${WORKDIR}/supercop-${MY_SUPERCOP_REV}" "${S}/external/supercop" || die
}

src_configure() {
	local mycmakeargs=(
		# They may not actually be built (see make targets)
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
	local targets=()
}

src_install() {
	# Install all binaries.
	find "${BUILD_DIR}/bin/" -type f -executable -print0 |
		while IFS= read -r -d '' line; do
			dobin "$line"
		done

	if use daemon; then
		insinto /etc/${PN}
		newins "${FILESDIR}"/${PN}d-0.9.2.2.${PN}d.conf ${PN}d.conf

		newconfd "${FILESDIR}"/${PN}d-0.9.2.2.confd ${PN}d
		newinitd "${FILESDIR}"/${PN}d-0.9.2.2.initd ${PN}d

		systemd_newunit "${FILESDIR}"/${PN}d-0.9.2.2.service ${PN}d.service
	fi
}

pkg_postinst() {
	if use daemon; then
		einfo "Start the Wownero P2P daemon as a system service with"
		einfo "'rc-service wownerod start'. Enable it at startup with"
		einfo "'rc-update add wownerod default'."
		einfo
		einfo "Run wownero status as any user to get sync status and other stats."
		einfo
		einfo "The Monero blockchain can take up a lot of space (80 GiB) and is stored"
		einfo "in /var/lib/wownero by default. You may want to enable pruning by adding"
		einfo "'prune-blockchain=1' to /etc/wownero/wownerod.conf to prune the blockchain"
		einfo "or move the data directory to another disk."
	fi
}
