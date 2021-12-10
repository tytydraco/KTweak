#!/usr/bin/env bash

BRANCHES=(balance budget latency throughput)
SCRIPT_PARENT_PATH="system/bin"
SCRIPT_NAME="ktweak"
SCRIPT_PATH="$SCRIPT_PARENT_PATH/$SCRIPT_NAME"

mkdir -p "$SCRIPT_PARENT_PATH"
rm -rf KTweak-MM*.zip

for branch in ${BRANCHES[@]}
do
	echo " * Building $branch..."
	TIMESTAMP="$(date +%F_%M-%H-%S)"
	HASH="$(git rev-parse HEAD)"
	ZIP="KTweak-MM-${branch}_${TIMESTAMP}_${HASH}.zip"

	echo " * Checking out script..."
	git show "$branch":"$SCRIPT_NAME" > "$SCRIPT_PATH"

	echo " * Patching for Android..."
	sed -i 's|!/usr/bin/env bash|!/system/bin/sh|g' "$SCRIPT_PATH"

	echo

	zip -0 -r -ll "$ZIP" META-INF/ build.sh customize.sh module.prop service.sh system/
done

echo " * Done!"
