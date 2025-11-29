# Maintainer: Vince R

pkgname=pluto-os-system-config
pkgver=1.0.0
pkgrel=1
pkgdesc="PlutoOS System Configuration"
arch=('x86_64')
url="https://github.com/77Z/pluto_os_system_config"
license=('MIT')
depends=()
makedepends=()
source=()
sha256sums=()

build() {
	flutter build linux --release
}

package() {
	install -dm755 "$pkgdir/pluto/system_config"
	cp -r $srcdir/../build/linux/x64/release/bundle/* "$pkgdir/pluto/system_config"

	install -Dm644 $srcdir/../dev._77z.pluto.system_config.desktop "$pkgdir/usr/share/applications/dev._77z.pluto.system_config.desktop"
	install -Dm644 $srcdir/../PlutoSystemConfig.png "$pkgdir/usr/share/pixmaps/PlutoSystemConfig.png"
}
