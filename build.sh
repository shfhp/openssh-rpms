#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
echo "Script directory: ${script_dir}"

COMPILE_SCRIPT=${script_dir}/compile.sh
VERSION_ENV=${script_dir}/version.env
LOG_FILE=${script_dir}/compile.log

# shellcheck source=/dev/null
source "${VERSION_ENV}"

echo "1. Modify the script execute permissions ..."
chmod +x "${script_dir}"/*.sh  || exit 1

if [ "$1" == 'lint' ]; then
    rpm -q rpmlint >/dev/null || yum install -y rpmlint
    rpmlint -v "$("${COMPILE_SCRIPT}" GETEL)"/SPECS/openssh.spec
    exit 0
fi

ARCH=$(uname -m)
RPM_DIR=$("${COMPILE_SCRIPT}" RPMDIR)
export RPM_DIR
OS=$("${COMPILE_SCRIPT}" GETOS)
VERSION=$(echo "$OPENSSHSRC" | grep -oE '[0-9.]+p[0-9]+')
TAGS_DIR=${script_dir}/tags
TGZ_FILE=${TAGS_DIR}/openssh-${VERSION}-${PKGREL}${OS}.${ARCH}.rpm.tar.gz
PKG_DIR=openssh-rpms

echo "2. Compile the openssh ${VERSION} RPMS pacakge ..."
"${COMPILE_SCRIPT}" &> "${LOG_FILE}" || exit 1

echo "3. List RPMS pacakge ..."
"${COMPILE_SCRIPT}" GETRPM

echo "4. Package and release package: ${TGZ_FILE}"
rm -rf "${TAGS_DIR}"
mkdir -p "${TAGS_DIR}" || exit 1
rm -rf "${RPM_DIR}"/openssh-debug*.rpm
cd "${script_dir}" || exit 1
rm -rf ./${PKG_DIR}
mkdir -p ${PKG_DIR}
cp "${RPM_DIR}"/*.rpm ${PKG_DIR}
cp ./install.sh ${PKG_DIR}
tar -zcf "${TGZ_FILE}" ${PKG_DIR}
tar -tf "${TGZ_FILE}"
