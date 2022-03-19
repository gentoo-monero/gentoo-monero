# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#To prevent confusion with the bitcoin version of p2pool, this ebuild
#has been named p2pool-monero
DESCRIPTION="Decentralized pool for Monero mining"
HOMEPAGE="https://p2pool.io https://github.com/SChernykh/p2pool"
SRC_URI="
	amd64?   ( https://github.com/SChernykh/p2pool/releases/download/v${PV}/p2pool-v${PV}-linux-x64.tar.gz )
	arm64? ( https://github.com/SChernykh/p2pool/releases/download/v${PV}/p2pool-v${PV}-linux-aarch64.tar.gz )
"

LICENSE="BSD GPL-3+ ISC LGPL-3+ MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

src_unpack(){
	if use "amd64"; then
		unpack p2pool-v${PV}-linux-x64.tar.gz
		mv -T "${WORKDIR}"/p2pool-v${PV}-linux-x64 "${S}"
	fi
	if use "aarch64"; then
		unpack p2pool-v${PV}-linux-aarch64.tar.gz
		mv -T "${WORKDIR}"/p2pool-v${PV}-linux-aarch64 "${S}"
	fi
}

src_install() {
	dobin "${S}"/p2pool
}

pkg_postinst() {
	#Some important wisdom taken from P2Pool documentation
	ewarn "P2Pool for Monero is now installed as a static binary."
	ewarn ""
	ewarn "You can run it by doing 'p2pool --host 127.0.0.1 --wallet YOUR_PRIMARY_ADDRESS'"
	ewarn "Where 127.0.0.1 is the address of a local monero node (e.g. monerod)"
	ewarn ""
	ewarn "Once configured, point your RandomX miner (e.g. XMRig) at p2pool"
	ewarn "For example 'xmrig -o 127.0.0.1:3333'"
	ewarn ""
	ewarn "You MUST use your primary address when using p2pool, just like solo mining."
	ewarn "If you want privacy, create a new mainnet wallet for P2Pool mining."
	ewarn ""
	ewarn "Rewards will not be visibile unless you use a wallet that supports P2Pool."
	ewarn "See https://p2pool.io/#help and https://github.com/SChernykh/p2pool for more information."
}
