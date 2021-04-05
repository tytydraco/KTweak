# Maintainer:

pkgname=ktweak-git
pkgver=1.0.ac279a9
pkgrel=1
pkgdesc="KTweak - A no-nonsense kernel tweak script for Linux and Android systems, backed by evidence"
arch=('any')
url="https://github.com/frap129/KTweak.git"
license=('GPL3')
depends=()
makedepends=('git')
source=("$pkgname"::'git+https://github.com/frap129/ktweak')
md5sums=('SKIP')
provides=(ktweak)

pkgver() {
  cd "$pkgname"
  echo "1.0.`git rev-parse --short HEAD`"
}

package() {
  cd "$srcdir/${pkgname}/"
  chmod +x ktweak
  mkdir -p "$pkgdir/usr/bin/"
  mkdir -p "$pkgdir/etc/systemd/system/"
  install -Dm744 ktweak "$pkgdir/usr/bin/ktweak"
  install -Dm644 ktweak.service "$pkgdir/etc/systemd/system/ktweak.service"
}
