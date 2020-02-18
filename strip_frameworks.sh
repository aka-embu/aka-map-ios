#! /bin/sh

## Adapted from:
## http://ikennd.ac/blog/2015/02/stripping-unwanted-architectures-from-dynamic-libraries-in-xcode/
## Daniel Kennett

## (Copyright on his code is uncertain, so this is an adaptation from his idea)
##
## Akamai Technologies, Inc.
## 16-May-2017

if [ "${CONFIGURATION}" = "Debug" ]
then
    echo "No stripping for Debug build"
    exit 0
fi

function strip_unnecessary_archs() {
    set -e
    local framework="${1}"
    local basename=$( basename "${framework}" )
    echo
    echo "Processing Framework: ${basename}"

    local filename=$( defaults read "${framework}/Info.plist" CFBundleExecutable )
    local image="${framework}/${filename}"

    local extracted=()
    local arch

    echo "** Image: ${image}"

    lipo -info "${image}"

    for arch in $ARCHS
    do
		echo "** Extracting ${arch} from ${basename}"
		lipo -extract "${arch}" "${image}" -o "${image}-${arch}" || {
			echo "** Skipping framework since lipo extract failed (already single architecture?): ${image}"
			return
		}
		extracted+=("${image}-${arch}")
    done

    echo "** Merging architectures ${ARCHS}"
    lipo -o "${image}-new" -create "${extracted[@]}"
    rm "${extracted[@]}"

    echo "** Rebuilding ${basename} image"
    rm -f "${image}"
    mv "${image}-new" "${image}"
    
    lipo -info "${image}"

    set +e
}

EXECUTABLE="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
basename=$( basename "${EXECUTABLE}" )
echo "Looking through ${basename} for FAT frameworks"

find "${EXECUTABLE}" -name '*.framework' -type d -print | \
while read framework; do
    strip_unnecessary_archs "${framework}"
done
