# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3 systemd

DESCRIPTION="The secure, private, untraceable cryptocurrency"
HOMEPAGE="https://www.getmonero.org https://github.com/monero-project/monero"
SRC_URI=""
EGIT_REPO_URI="https://github.com/monero-project/monero.git"
EGIT_COMMIT="v${PV}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon hw-wallet libressl readline tools +wallet-cli +wallet-rpc"
REQUIRED_USE="|| ( daemon tools wallet-cli wallet-rpc )"

DEPEND="
	acct-group/monero
	acct-user/monero
	dev-libs/boost:=[nls,threads]
	dev-libs/libsodium:=
	net-dns/unbound:=[threads]
	net-libs/czmq:=
	hw-wallet? (
		dev-libs/hidapi
		dev-libs/protobuf:=
		virtual/libusb:1
	)
	!libressl? ( dev-libs/openssl:= )
	libressl? ( dev-libs/libressl:= )
	readline? ( sys-libs/readline:0= )"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=("${FILESDIR}/${PN}-0.17.1.3-linkjobs.patch")

src_configure() {
	local mycmakeargs=(
		# Monero's liblmdb conflicts with the system liblmdb :(
		-DBUILD_SHARED_LIBS=OFF
		-DMANUAL_SUBMODULES=ON
		-DMONERO_PARALLEL_LINK_JOBS=1
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

		# data-dir
		keepdir /var/lib/monero
		fowners monero:monero /var/lib/monero
		fperms 0755 /var/lib/monero

		# log-file dir
		keepdir /var/log/monero
		fowners monero:monero /var/log/monero
		fperms 0755 /var/log/monero

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
