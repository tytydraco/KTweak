#!/usr/bin/env bash

TIMESTAMP="$(date +%F_%M-%H-%S)"
HASH="$(git rev-parse HEAD)"
ZIP="KTweak-MM_${TIMESTAMP}_${HASH}.zip"

rm -f KTweak-MM_*.zip
zip -0 -r -ll "$ZIP" META-INF/ customize.sh module.prop service.sh
