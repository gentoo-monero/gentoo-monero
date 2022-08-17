# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

MY_MINIUPNP_REV="544e6fcc73c5ad9af48a8985c94f0f1d742ef2e0"
MY_RANDOMX_REV="85c527a62301b7b8be89d941020308b1cb92b75c"
MY_SUPERCOP_REV="633500ad8c8759995049ccd022107d1fa8a1bbc9"
MY_TREZOR_REV="bff7fdfe436c727982cc553bdfb29a9021b423b0"

DESCRIPTION="The secure, private, untraceable cryptocurrency"
HOMEPAGE="https://www.getmonero.org https://github.com/monero-project/monero"
SRC_URI="
	https://github.com/monero-project/monero/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/miniupnp/miniupnp/archive/${MY_MINIUPNP_REV}.tar.gz -> ${PN}-miniupnp-${PV}.tar.gz
	https://github.com/tevador/RandomX/archive/${MY_RANDOMX_REV}.tar.gz -> ${PN}-randomx-${PV}.tar.gz
	https://github.com/monero-project/supercop/archive/${MY_SUPERCOP_REV}.tar.gz -> ${PN}-supercop-${PV}.tar.gz
	hw-wallet? ( https://github.com/trezor/trezor-common/archive/${MY_TREZOR_REV}.tar.gz -> ${PN}-trezor-common-${PV}.tar.gz )
"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon hw-wallet readline tools +wallet-cli +wallet-rpc"
REQUIRED_USE="|| ( daemon tools wallet-cli wallet-rpc )"

RESTRICT="test"

DEPEND="
	dev-libs/boost:=[nls,threads(+)]
	dev-libs/libsodium:=
	dev-libs/openssl:=
	dev-libs/rapidjson
	net-dns/unbound:=[threads]
	net-libs/czmq:=
	hw-wallet? (
		dev-libs/hidapi
		dev-libs/protobuf:=
		virtual/libusb:1
	)
	readline? ( sys-libs/readline:0= )"
RDEPEND="
	${DEPEND}
	acct-group/monero
	acct-user/monero"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-0.17.1.9-no-git.patch"
)

src_unpack() {
	default
	rmdir "${S}"/external/{miniupnp,randomx,supercop,trezor-common} || die
	mv "${WORKDIR}/miniupnp-${MY_MINIUPNP_REV}" "${S}/external/miniupnp" || die
	mv "${WORKDIR}/RandomX-${MY_RANDOMX_REV}" "${S}/external/randomx" || die
	mv "${WORKDIR}/supercop-${MY_SUPERCOP_REV}" "${S}/external/supercop" || die
	use hw-wallet && (mv "${WORKDIR}/trezor-common-${MY_TREZOR_REV}" "${S}/external/trezor-common" || die)
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCUMENTATION=OFF
		# Monero's liblmdb conflicts with the system liblmdb :(
		-DBUILD_SHARED_LIBS=OFF
		-DMANUAL_SUBMODULES=ON
		-DMONERO_PARALLEL_LINK_JOBS=1
		# The user can decide for themselves if they want to use ccache.
		-DUSE_CCACHE=OFF
		-DUSE_DEVICE_TREZOR=$(usex hw-wallet)
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
		dodoc utils/conf/monerod.conf

		# /etc/monero/monerod.conf
		insinto /etc/monero
		newins "${FILESDIR}/monerod-0.16.0.3-r1.monerod.conf" monerod.conf

		# OpenRC
		newconfd "${FILESDIR}/monerod-0.16.0.3-r1.confd" monerod
		newinitd "${FILESDIR}/monerod-0.16.0.3-r1.initd" monerod

		# systemd
		systemd_newunit "${FILESDIR}/monerod-0.17.1.5.service" monerod.service
	fi
}

pkg_postinst() {
	if use daemon; then
		einfo "Start the Monero P2P daemon as a system service with"
		einfo "'rc-service monerod start'. Enable it at startup with"
		einfo "'rc-update add monerod default'."
		einfo
		einfo "Run monerod status as any user to get sync status and other stats."
		einfo
		einfo "The Monero blockchain can take up a lot of space (80 GiB) and is stored"
		einfo "in /var/lib/monero by default. You may want to enable pruning by adding"
		einfo "'prune-blockchain=1' to /etc/monero/monerod.conf to prune the blockchain"
		einfo "or move the data directory to another disk."
	fi
}
