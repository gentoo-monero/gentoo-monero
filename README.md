# Gentoo Monero Overlay

## Getting Started

### `eselect-repository`

```bash
# Install eselect-repository, if you don't already have it.
emerge --ask --noreplace eselect-repository

# Enable the overlay.
eselect repository enable monero

# Sync the overlay.
emaint sync --repo monero

# Unmask everything in the overlay.
echo '*/*::monero ~amd64' >> /etc/portage/package.accept_keywords

# Install some software!
emerge --ask net-p2p/monero
```

### Manual

```bash
# Add overlay to repos.conf.
cat << EOF > /etc/portage/repos.conf/monero.conf
[monero]
location = /var/db/repos/monero
sync-type = git
sync-uri = https://github.com/gentoo-monero/gentoo-monero.git
EOF

# Sync the overlay.
emaint sync --repo monero

# Unmask everything in the overlay.
echo '*/*::monero ~amd64' >> /etc/portage/package.accept_keywords

# Install some software!
emerge --ask net-p2p/monero
```

## Contributing

Contributions of all types are welcome.
Feel free to make a pull request!
See [CONTRIBUTING.md](CONTRIBUTING.md) in the project root for more info.
