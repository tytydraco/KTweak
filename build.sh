#!/usr/bin/env bash

BRANCHES=(balance budget latency throughput)

rm -rf KTweak-MM*.zip

for branch in ${BRANCHES[@]}
do
	echo " * Building $branch..."
	TIMESTAMP="$(date +%F_%M-%H-%S)"
	HASH="$(git rev-parse HEAD)"
	ZIP="KTweak-MM-${branch}_${TIMESTAMP}_${HASH}.zip"

	cp customize.sh customize.sh.bk
	sed -i "s/BRANCH=\"balance\"/BRANCH=\"$branch\"/" customize.sh
	zip -0 -r -ll "$ZIP" META-INF/ customize.sh module.prop service.sh
	mv customize.sh.bk customize.sh

	echo
done
