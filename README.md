# Gentoo Monero Overlay

## Getting Started

1. Enable the overlay:

        # Install eselect-repository, if you don't already have it.
        emerge eselect-repository
        
        # Enable the overlay.
        eselect repository enable monero

2. Unmask everything in the overlay:

        echo '*/*::monero ~amd64' >> /etc/portage/package.accept_keywords

3. Install software!:

        emerge net-misc/xmrig
